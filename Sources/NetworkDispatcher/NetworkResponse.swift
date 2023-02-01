//
//  NetworkResponse.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/27/23.
//

import Foundation

public final class NetworkResponse {

    public let statusCode: Int
    public let data: Data?
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let apiClient: APIClient
    
    public init(
        statusCode: Int,
        data: Data?,
        request: URLRequest? = nil,
        response: HTTPURLResponse? = nil,
        apiClient: APIClient
    ) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
        self.apiClient = apiClient
    }

    public var description: String {
        return "Status Code: \(statusCode), Data Length: \(String(describing: data?.count))"
    }
}
