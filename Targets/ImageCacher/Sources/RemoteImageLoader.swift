//
//  RemoteImageLoader.swift
//  ImageCacher
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import HttpClient

public struct RemoteImageLoader : ImageLoader {
    
    private let httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func load(from url: URL) async throws -> Data {
        let data = await httpClient.getData(from: url)
        switch data {
        case .success(let data):
            return data
        case .failure(let error):
            throw ImageLoaderError.httpError(error)
        }
    }
}
