//
//  CacheImageLoader.swift
//  ImageCacher
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

public struct CacheImageLoader : ImageLoader, ImageSaver {
    
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func filePathFor(url: URL) -> String {
        let fileName = url.relativeString
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let path = cachesDirectory.appendingPathComponent("\(fileName).cache")
        return path.path
    }
    
    public func fileExists(from url: URL) -> Bool {
        let path = filePathFor(url: url)
        return fileManager.fileExists(atPath: path)
    }
    
    public func load(from url: URL) async throws -> Data {
        let path = filePathFor(url: url)
        guard fileManager.fileExists(atPath: path),
              let data = fileManager.contents(atPath: path)
        else { throw ImageLoaderError.notFound }
        return data
    }
    
    public func save(data: Data, from url: URL) async {
        let path = filePathFor(url: url)
        fileManager.createFile(atPath: path, contents: data)
    }
    
}
