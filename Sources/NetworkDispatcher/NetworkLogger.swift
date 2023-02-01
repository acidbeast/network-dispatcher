//
//  NetworkLogger.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/30/23.
//

import Foundation

public protocol NetworkLoggerProtocol {
    func log(request: URLRequest)
    func log(response: HTTPURLResponse, data: Data?)
}

public final class NetworkLogger: NetworkLoggerProtocol {
    public func log(request: URLRequest) {
        print("------------ REQUEST -------------")
        defer { print("---------------------------------- \n") }
        let urlString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlString)
        let method = request.httpMethod ?? ""
        let path = urlComponents?.path ?? ""
        let query = urlComponents?.query ?? ""
        let host = urlComponents?.host ?? ""
        var output = "\(urlString)\n"
        output += "Host: \(host)\n"
        output += "\(method) \(path)?\(query)\n"
        let headerFields = request.allHTTPHeaderFields ?? [:]
        if headerFields.count > 0 {
            output += "Headers:\n"
            for (key,value) in request.allHTTPHeaderFields ?? [:] {
                output += "\(key): \(value) \n"
            }
        }
        if let body = request.httpBody {
            output += "\(String(decoding: body, as: UTF8.self))\n"
        }
        print(output)
    }
    
    public func log(response: HTTPURLResponse, data: Data?) {
        print("------------ RESPONSE ------------")
        defer { print("----------------------------------\n") }
        if let responseUrl = response.url {
            print("URL: \(responseUrl)")
        }
        print("Status code: \(response.statusCode)")
        if let data = data {
            let dataString = String(decoding: data, as: UTF8.self)
            print("\(dataString)")
        }
    }
}
