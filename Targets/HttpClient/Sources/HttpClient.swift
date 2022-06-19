//
//  HttpClient.swift
//  HttpClient
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation

public protocol HTTPClient {
    func getData(from url: URL) async -> Result<Data, HTTP.ClientError>
}

public enum HTTP {
    
}

extension HTTP {
    public enum ClientError: Error {
        case networkError, badRequest
    }
}
