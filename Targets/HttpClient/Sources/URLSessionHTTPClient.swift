//
//  URLSessionHTTPClient.swift
//  HttpClient
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession)  {
        self.session = session
    }
    
    func getJSON<T : Decodable>(from url: URL, type: T.Type) async -> Result<T, HTTP.ClientError> {
        do {
            let (data, urlResponse) = try await session.data(for: URLRequest(url: url))
            if let httpResposne = urlResponse as? HTTPURLResponse,
               httpResposne.statusCode < 200 || httpResposne.statusCode >= 300 {
                return .failure(.badRequest)
            }
            let entity = try JSONDecoder().decode(type, from: data)
            return .success(entity)
        } catch let error as DecodingError {
            debugPrint(error)
            return .failure(.cantDecode)
        } catch {
            return .failure(.networkError)
        }
    }
}
