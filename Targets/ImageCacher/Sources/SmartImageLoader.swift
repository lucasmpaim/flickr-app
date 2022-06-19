//
//  SmartImageLoader.swift
//  ImageCacher
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

public struct SmartImageLoader : ImageLoader {
    
    private let remoteLoader: RemoteImageLoader
    private let cacheLoader: CacheImageLoader
    
    public init(remoteLoader: RemoteImageLoader, cacheLoader: CacheImageLoader) {
        self.remoteLoader = remoteLoader
        self.cacheLoader = cacheLoader
    }
    
    public func load(from url: URL) async throws -> Data {
        if cacheLoader.fileExists(from: url) {
            return try await cacheLoader.load(from: url)
        }
        let data = try await remoteLoader.load(from: url)
        await cacheLoader.save(data: data, from: url)
        return data
    }
    
}
