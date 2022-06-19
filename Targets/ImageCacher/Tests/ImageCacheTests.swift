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
    func load(from url: URL) async throws -> Data
}

protocol ImageSaver {
    func save(data: Data, from url: URL) async
}

struct RemoteImageLoader : ImageLoader {
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func load(from url: URL) async throws -> Data {
        let data = await httpClient.getData(from: url)
        switch data {
        case .success(let data):
            return data
        case .failure(let error):
            throw ImageLoaderError.httpError(error)
        }
    }
}

struct CacheImageLoader : ImageLoader, ImageSaver {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func filePathFor(url: URL) -> String {
        let fileName = url.relativeString
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let path = cachesDirectory.appendingPathComponent("\(fileName).cache")
        return path.path
    }
    
    func load(from url: URL) async throws -> Data {
        let path = filePathFor(url: url)
        guard fileManager.fileExists(atPath: path),
              let data = fileManager.contents(atPath: path)
        else { throw ImageLoaderError.notFound }
        return data
    }
    
    func save(data: Data, from url: URL) async {
        let path = filePathFor(url: url)
        fileManager.createFile(atPath: path, contents: data)
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
    
    func test_saveImageWillCreateFileOnCorrectPlace() async {
        let sut = CacheImageLoader()
        let path = sut.filePathFor(url: anyURL())
        addTeardownBlock { try? FileManager.default.removeItem(atPath: path) }
        await sut.save(data: anyData(), from: anyURL())
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }
    
    func test_afterSaveImageLoadDataFromCache_shouldReturnData() async {
        let sut = CacheImageLoader()
        let path = sut.filePathFor(url: anyURL())
        addTeardownBlock { try? FileManager.default.removeItem(atPath: path) }
        await sut.save(data: anyData(), from: anyURL())
        
        do {
            let data = try await sut.load(from: anyURL())
            XCTAssertEqual(data, anyData())
        } catch let error {
            XCTFail("Expect to receive data, got \(error) instead")
        }
    }
    
    func test_loadRemoteImage_shouldReturnData() async {
        let httpClient = MockHTTPClient(stub: .success(anyData()))
        let sut = RemoteImageLoader(httpClient: httpClient)
        let data = try? await sut.load(from: anyURL())
        XCTAssertEqual(data, anyData())
    }
    
    func test_whenFailureToFetchRemoteImage_shouldThrowAnError() async {
        let httpClient = MockHTTPClient(stub: .failure(.networkError))
        let sut = RemoteImageLoader(httpClient: httpClient)
        do {
            let data = try await sut.load(from: anyURL())
            XCTFail("Expect to receive an error, got \(data) instead")
        } catch let error as ImageLoaderError {
            XCTAssertEqual(error, .httpError(.networkError))
        } catch let error {
            XCTFail("Expect to receive an ImageLoaderError error, got \(error) instead")
        }
    }
}

// MARK: - Helpers
fileprivate extension ImageCacheTests {
    func anyURL() -> URL { URL(string: "https://google.com.br")! }
    func anyData() -> Data { Data("some data".utf8) }
    
    
    class MockHTTPClient: HTTPClient {
        let stub: Result<Data, HTTP.ClientError>
        
        init(stub: Result<Data, HTTP.ClientError>) {
            self.stub = stub
        }
        
        private(set) var getDataMessages: [URL] = []
        func getData(from url: URL) async -> Result<Data, HTTP.ClientError> {
            getDataMessages.append(url)
            return stub
        }
    }
}


extension ImageLoaderError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound): return true
        case (.httpError(.networkError), .httpError(.networkError)): return true
        default: return false
        }
    }
}
