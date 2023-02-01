//
//  NetworkDispatcher.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/27/23.
//

import Foundation

public final class NetworkDispatcher<APIClientType: APIClient> {
    
    private let cachePolicy: URLRequest.CachePolicy
    private let timeoutInterval: TimeInterval
    private let session: URLSession
    private let logger: NetworkLoggerProtocol?
    
    private var task: URLSessionTask?
    
    init (
        requestTimeout: TimeInterval = 10.0,
        cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        session: URLSession,
        logger: NetworkLoggerProtocol = NetworkLogger.init()
    ) {
        self.timeoutInterval = requestTimeout
        self.cachePolicy = cachePolicy
        self.session = session
        self.logger = logger
    }
      
    public func request(
        _ apiClient: APIClientType,
        completion: @escaping (NetworkResult<NetworkResponse, NetworkError>) -> ()
    ) {
        do {
            let request = try self.buildRequest(from: apiClient)
            logger?.log(request: request)
            task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                let result: NetworkResult<NetworkResponse, NetworkError>
                if error != nil {
                    result = .failure(.netwotkError)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        result = .failure(.netwotkError)
                        return
                    }
                    let requestResponse = NetworkResponse(
                        statusCode: httpResponse.statusCode,
                        data: data,
                        request: request,
                        response: httpResponse,
                        apiClient: apiClient
                    )
                    result = .success(requestResponse)
                    self?.logger?.log(response: httpResponse, data: data)
                }
                completion(result)
            })
        } catch {
            completion(.failure(.unknownError))
        }
        self.task?.resume()
    }
    
    public func handle<DataType: Decodable>(
        result: NetworkResult<NetworkResponse, NetworkError>,
        onSuccess: @escaping (DataType) -> Void,
        onError: ((NetworkError) -> Void)? = nil
    ) {
        switch result {
        case .failure(let error):
            if let onError = onError {
                onError(error)
            }
        case .success(let response):
            switch response.statusCode {
            case 200, 201:
                guard let responseData = response.data else {
                    if let onError = onError {
                        onError(.decodingError)
                    }
                    return
                }
                do {
                    guard DataType.self == String.self else {
                        let decodedData = try response.apiClient.decoder.decode(DataType.self, from:responseData)
                        onSuccess(decodedData)
                        return
                    }
                    guard let stringResponse = String(data: response.data!, encoding: .utf8) as? DataType else {
                            if let onError = onError {
                                onError(.decodingError)
                            }
                        return
                    }
                    onSuccess(stringResponse)
                } catch {
                    if let onError = onError {
                        onError(.encodingError)
                    }
                }
                break
            case 401:
                if let onError = onError {
                    onError(.unauthorized)
                }
            case 402:
                if let onError = onError {
                    onError(.error4xx(response.statusCode))
                }
            case 403:
                if let onError = onError {
                    onError(.forbidden)
                }
            case 404:
                if let onError = onError {
                    onError(.notFound)
                }
            case 405...499:
                if let onError = onError {
                    onError(.error4xx(response.statusCode))
                }
            case 500:
                if let onError = onError {
                    onError(.serverError)
                }
            case 500...599:
                if let onError = onError {
                    onError(.error5xx(response.statusCode))
                }
            default:
                if let onError = onError {
                    onError(.unknownError)
                }
            }
        }
    }
    
    public func cancel() {
        self.task?.cancel()
    }
    
    // MARK: - Configuration
    fileprivate func buildRequest(from client: APIClientType) throws -> URLRequest {
        let requestURL: URL        
        if #available(iOS 16.0, *) {
            requestURL = client.baseURL.appending(path: client.path)
        } else {
            requestURL = client.baseURL.appendingPathComponent(client.path)
        }
        var request = URLRequest(
            url: requestURL,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0
        )
        request.httpMethod = client.httpMethod.rawValue
        do {
            switch client.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters, let urlParameters):
                try self.configureParameters(
                    bodyParameters: bodyParameters,
                    urlParameters: urlParameters,
                    request: &request
                )
            case .requestParametersAndHeaders(
                let bodyParameters,
                let urlParameters,
                let additionalHeaders):
                self.addHeaders(additionalHeaders, request: &request)
                try self.configureParameters(
                    bodyParameters: bodyParameters,
                    urlParameters: urlParameters,
                    request: &request
                )
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(
        bodyParameters: [String: Any]?,
        urlParameters: [String: Any]?,
        request: inout URLRequest
    ) throws {
        do {
            if let bodyParameters {
                try self.encodeJSON(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters {
                try self.encodeParams(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func addHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    fileprivate func encodeParams(urlRequest: inout URLRequest, with parameters: [String: Any]) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        if var
            urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
           !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            for (key,value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-encoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
    
    fileprivate func encodeJSON(urlRequest: inout URLRequest, with parameters: [String: Any]) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingError
        }
    }
}
