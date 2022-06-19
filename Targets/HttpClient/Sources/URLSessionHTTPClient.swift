//
//  URLSessionHTTPClient.swift
//  HttpClient
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession)  {
        self.session = session
    }
    
    public func getData(from url: URL) async -> Result<Data, HTTP.ClientError> {
        do {
            let (data, urlResponse) = try await session.data(for: URLRequest(url: url))
            if let httpResposne = urlResponse as? HTTPURLResponse,
               httpResposne.statusCode < 200 || httpResposne.statusCode >= 300 {
                debugPrint("Bad Request On Call: \(url)")

                return .failure(.badRequest)
            }
            return .success(data)
        } catch {
            return .failure(.networkError)
        }
    }
}
