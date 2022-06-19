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
    
    public func getJSON<T : Decodable>(from url: URL, type: T.Type) async -> Result<T, HTTP.ClientError> {
        do {
            let result = await getData(from: url)
            switch result {
            case .success(let data):
                let entity = try JSONDecoder().decode(type, from: data)
                return .success(entity)
            case .failure(let error):
                return .failure(error)
            }
        } catch let error as DecodingError {
            debugPrint(error)
            return .failure(.cantDecode)
        } catch {
            return .failure(.networkError)
        }
    }
    
    public func getData(from url: URL) async -> Result<Data, HTTP.ClientError> {
        do {
            let (data, urlResponse) = try await session.data(for: URLRequest(url: url))
            if let httpResposne = urlResponse as? HTTPURLResponse,
               httpResposne.statusCode < 200 || httpResposne.statusCode >= 300 {
                return .failure(.badRequest)
            }
            return .success(data)
        } catch {
            return .failure(.networkError)
        }
    }
}
