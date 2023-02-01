//
//  APIClient.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/27/23.
//

import Foundation

public protocol APIClient {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var decoder: JSONDecoder { get }
}
