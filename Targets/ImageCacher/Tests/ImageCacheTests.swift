//
//  ImageCacheTests.swift
//  ImageCacheTests
//
//  Created by Lucas Paim on 19/06/22.
//

import XCTest

import HttpClient
@testable import ImageCacher

enum ImageLoaderError: Error {
    case notFound, httpError(HTTP.ClientError)
}

protocol ImageLoader {
    func load(from: URL) async throws -> Data
}

struct RemoteImageLoader : ImageLoader {
    func load(from: URL) async throws -> Data {
        fatalError()
    }
}

struct CacheImageLoader : ImageLoader {
    func load(from: URL) async throws -> Data {
        throw ImageLoaderError.notFound
    }
}

struct SmartImageLoader : ImageLoader {
    
    let remoteLoader: RemoteImageLoader
    let cacheLoader: CacheImageLoader
    
    init(remoteLoader: RemoteImageLoader, cacheLoader: CacheImageLoader) {
        self.remoteLoader = remoteLoader
        self.cacheLoader = cacheLoader
    }
    
    func load(from: URL) async throws -> Data {
        fatalError()
    }
    
}

final class ImageCacheTests: XCTestCase {
    func test_whenTryToLoadFromCacheAndDontExists_shoulTrowNotFoundError() async {
        let sut = CacheImageLoader()
        do {
            try await sut.load(from: anyURL())
        } catch let error as ImageLoaderError {
            XCTAssertEqual(error, .notFound)
        } catch let error {
            XCTFail("Expect not found error, got \(error) instead")
        }
    }
}

// MARK: - Helpers
fileprivate extension ImageCacheTests {
    func anyURL() -> URL { URL(string: "https://google.com.br")! }
    func anyData() -> Data { Data("some data".utf8) }
}


extension ImageLoaderError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound): return true
        default: return false
        }
    }
}
