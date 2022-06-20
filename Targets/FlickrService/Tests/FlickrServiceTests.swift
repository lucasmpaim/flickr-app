//
//  FlickrServiceTests.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 18/06/22.
//

import XCTest
import HttpClient
@testable import FlickrService

final class FlickrServiceTests: XCTestCase {
    func test_whenInvokeFetchPopularMethodShouldCallTheCorrectURL() async {
        let mockHTTPClient = HTTPClientMock(result: .failure(.networkError))
        let sut = FlickrServiceImpl(client: mockHTTPClient, photoMapper: PagedPhotoMapperJsonDecoder())
        let result = await sut.fetchPopular()
        XCTAssertEqual(mockHTTPClient.getDataMessages.count, 1)
        XCTAssertEqual(mockHTTPClient.getDataMessages.first?.relativeString, anyFlickrURL())
    }
    
    func test_pagedPhotoMapperShouldMakeCorrectParser() {
        let sut = PagedPhotoMapperJsonDecoder()
        do {
            let result = try sut.map(anyJson())
            XCTAssertEqual(result.photos.count, 1)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func test_whenInvokeFetchPopularMethod_shouldReturnDomainObjects() async {
        let mockHTTPClient = HTTPClientMock(result: .success(anyJson()))
        let sut = FlickrServiceImpl(client: mockHTTPClient, photoMapper: PagedPhotoMapperJsonDecoder())
        let result = await sut.fetchPopular()
        
        switch result {
        case .success(let page):
            XCTAssertEqual(page.photos.count, 1)
        case .failure(let error):
            XCTFail("Expect to receive a success message, got \(error) instead")
        }
    }
    
    func test_whenInvokeFetchPopularMethod_withInvalidJson_shouldFailWithCorrectError() async {
        let mockHTTPClient = HTTPClientMock(result: .success(anyInvalidJson()))
        let sut = FlickrServiceImpl(client: mockHTTPClient, photoMapper: PagedPhotoMapperJsonDecoder())
        let result = await sut.fetchPopular()
        
        switch result {
        case .success(let page):
            XCTFail("Expect to receive a failure message, got \(page) instead")
        case .failure(let error):
            XCTAssertEqual(error, .cantDecode)
        }
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
        "https://www.flickr.com/services/rest/?api_key=6ee86dfd9bce6f402e171ff247753cbd&format=json&extras=owner_name,date_upload&nojsoncallback=1&method=flickr.photos.getPopular&user_id=\(userId)"
    }
    
    func anyJson() -> Data {
        Data("""
        {
          "photos": {
            "page": 1,
            "pages": 1,
            "perpage": 100,
            "total": 100,
            "photo": [
              {
                "id": "51924461369",
                "owner": "139356341@N05",
                "secret": "db7fa363fd",
                "server": "65535",
                "farm": 66,
                "title": "Southwold Pier 3",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0,
                "dateupload": "1655675444",
                "ownername": "D. C. Peters"
              }
            ]
          },
          "stat": "ok"
        }
        """.utf8)
    }
    
    func anyInvalidJson() -> Data {
        Data("""
        {
          "photos": {
            "page": 1,
            "pages": 1,
            "perpage": 100,
            "total": 100,
            "photo": [
              {
                "id": "51924461369",
                "owner": "139356341@N05",
                "secret": "db7fa363fd",
                "server": "65535",
                "farm": 66,
                "title": "Southwold Pier 3",
                "ispublic": false,
                "isfriend": 0,
                "isfamily": 0,
                "dateupload": "1655675444",
                "ownername": "D. C. Peters"
              }
            ]
          },
          "stat": "ok"
        }
        """.utf8)
    }
}


extension Flickr.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.cantDecode, .cantDecode): return true
        default: return false
        }
    }
}
