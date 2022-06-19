//
//  FlickrServiceTests.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 18/06/22.
//

import XCTest
import HttpClient
@testable import FlickrService

enum Flickr {
    
}

extension Flickr {
    enum Error : Swift.Error {
        case httpError(HTTP.ClientError)
    }
}


struct RemotePage<T: Decodable>: Decodable {
    let page: UInt
    let pages: UInt
    let perpage: UInt
    let total: UInt
    let items: [T]
}

struct RemotoPhoto: Decodable {
    let id: String
    let secret: String
    let isPublic: Bool
    let title: String
}

struct Page<T> {
    let page: UInt
    let totalPages: UInt
    let perPage: UInt
    let items: [T]
}

struct Photo {
    let id: String
    let secret: String
    let isPublic: Bool
    let title: String
}

protocol FlickrService {
    func fetchPopular() async -> Result<Page<Photo>, Flickr.Error>
}

struct FlickrServiceImpl : FlickrService {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchPopular() async -> Result<Page<Photo>, Flickr.Error> {
        return .failure(.httpError(.networkError))
    }
}

final class FlickrServiceTests: XCTestCase {
    func test_whenInvokeFetchPopularMethodShouldReturnPopularPhotos() async {
//        let stubHttpClient = StubHTTPClient(stub: .failure(.networkError))
//        let sut = FlickrServiceImpl(client: stubHttpClient)
//
//        let result = await sut.fetchPopular()
//
//        switch result {
//        case .success(let page):
//            XCTAssertTrue(page.items.count > 0)
//        case .failure(let error):
//            XCTFail("Expect to receive a page, got \(error) instead")
//        }
        
    }
}


//MARK: - Help Methods

fileprivate extension FlickrServiceTests {
    final class StubHTTPClient: HTTPClient {
        
        private let stubResult: Result<Any, HTTP.ClientError>
        
        init(stub: Result<Any, HTTP.ClientError>) {
            self.stubResult = stub
        }
        
        func getData(from url: URL) async -> Result<Data, HTTP.ClientError> {
            fatalError("Not implemented")
        }
        
        func getJSON<T: Decodable>(from url: URL, type: T.Type) async -> Result<T, HTTP.ClientError> where T : Decodable {
            return stubResult as! Result<T, HTTP.ClientError>
        }
    }
}
