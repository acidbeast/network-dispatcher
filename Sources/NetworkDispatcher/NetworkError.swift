//
//  NetworkError.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/30/23.
//

import Foundation

public enum NetworkError: LocalizedError {
    case missingURL
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case encodingError
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case netwotkError
}
