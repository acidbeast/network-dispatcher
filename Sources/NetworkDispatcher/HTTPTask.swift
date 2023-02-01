//
//  HTTPTask.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/27/23.
//

import Foundation

public enum HTTPTask {
    case request
    case requestParameters(
        bodyParameters: [String: Any]?,
        urlParameters: [String: Any]?
    )
    case requestParametersAndHeaders(
        bodyParameters: [String: Any]?,
        urlParameters: [String: Any]?,
        headers: [String:String]?
    )
}
