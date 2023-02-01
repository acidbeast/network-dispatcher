//
//  NetworkResult.swift
//  NetworkDispatcher
//
//  Created by Dmitry Shlepkin on 1/29/23.
//

import Foundation

public enum NetworkResult<NetworkResponse, NetworkRequestError> {
    case success(NetworkResponse)
    case failure(NetworkRequestError)
}
