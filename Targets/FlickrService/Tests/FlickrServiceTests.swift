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
        case httpError(HTTP.ClientError), invalidURI
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
    func fetchPopular(userID: String?) async -> Result<Page<Photo>, Flickr.Error>
}

struct FlickrServiceImpl : FlickrService {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchPopular(userID: String? = nil) async -> Result<Page<Photo>, Flickr.Error> {
        guard let url = FlickrURLBuilder(method: .fetchPopularPhotos)
            .userId(userID)
            .build() else { return .failure(.invalidURI) }
        
        let response = await client.getData(from: url)
        
        switch response {
        case .success(let data):
            return .failure(.invalidURI)
        case .failure(let error):
            return .failure(.httpError(error))
        }
    }
}

final class FlickrServiceTests: XCTestCase {
    func test_whenInvokeFetchPopularMethodShouldCallTheCorrectURL() async {
        let mockHTTPClient = HTTPClientMock(result: .failure(.networkError))
        let sut = FlickrServiceImpl(client: mockHTTPClient)
        let result = await sut.fetchPopular()
        XCTAssertEqual(mockHTTPClient.getDataMessages.count, 1)
        XCTAssertEqual(mockHTTPClient.getDataMessages.first?.relativeString, anyFlickrURL())
    }
}


//MARK: - Help Methods

fileprivate extension FlickrServiceTests {
    final class HTTPClientMock: HTTPClient {
        
        private let result: Result<Data, HTTP.ClientError>
        
        init(result: Result<Data, HTTP.ClientError>) {
            self.result = result
        }
        
        private(set) var getDataMessages: [URL] = []
        func getData(from url: URL) async -> Result<Data, HTTP.ClientError> {
            getDataMessages.append(url)
            return result
        }
    }
    
    func anyFlickrURL(userId: String = "139356341%40N05") -> String {
        "https://www.flickr.com/services/rest/?api_key=6ee86dfd9bce6f402e171ff247753cbd&format=json&method=flickr.photos.getPopular&user_id=\(userId)"
    }
}
