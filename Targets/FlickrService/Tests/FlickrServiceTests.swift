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
        case httpError(HTTP.ClientError), invalidURI, cantDecode
    }
}

struct RemoteWrapper: Decodable {
    let photos: RemotePhotoPage
}

struct RemotePhotoPage: Decodable {
    let page: UInt
    let pages: UInt
    let perpage: UInt
    let total: UInt
    let photo: [RemotePhoto]
}

struct RemotePhoto: Decodable {
    let id: String
    let secret: String
    let ispublic: UInt
    let title: String
}

struct PhotoPage {
    let page: UInt
    let totalPages: UInt
    let perPage: UInt
    let photos: [Photo]
}

struct Photo {
    let id: String
    let secret: String
    let isPublic: Bool
    let title: String
}

extension Photo {
    init(remote: RemotePhoto) {
        self.init(
            id: remote.id,
            secret: remote.secret,
            isPublic: remote.ispublic == 1,
            title: remote.title
        )
    }
}

extension PhotoPage {
    init(remote: RemotePhotoPage) {
        self.init(
            page: remote.page,
            totalPages: remote.pages,
            perPage: remote.perpage,
            photos: remote.photo.map { Photo(remote: $0) }
        )
    }
}


protocol PagedPhotoMapper {
    func map(_ data: Data) throws -> RemotePhotoPage
}

struct PagedPhotoMapperJsonDecoder : PagedPhotoMapper {
    func map(_ data: Data) throws -> RemotePhotoPage {
        let wrapper = try JSONDecoder().decode(RemoteWrapper.self, from: data)
        return wrapper.photos
    }
}

protocol FlickrService {
    func fetchPopular(userID: String?) async -> Result<PhotoPage, Flickr.Error>
}

struct FlickrServiceImpl : FlickrService {
    
    private let client: HTTPClient
    private let photoMapper: PagedPhotoMapper
    
    init(
        client: HTTPClient,
        photoMapper: PagedPhotoMapper
    ) {
        self.client = client
        self.photoMapper = photoMapper
    }
    
    func fetchPopular(userID: String? = nil) async -> Result<PhotoPage, Flickr.Error> {
        guard let url = FlickrURLBuilder(method: .fetchPopularPhotos)
            .userId(userID)
            .build() else { return .failure(.invalidURI) }
        
        let response = await client.getData(from: url)
        
        switch response {
        case .success(let data):
            return map(data: data)
        case .failure(let error):
            return .failure(.httpError(error))
        }
    }
    
    fileprivate func map(data: Data) -> Result<PhotoPage, Flickr.Error> {
        do {
            let result = try photoMapper.map(data)
            return .success(PhotoPage(remote: result))
        } catch {
            return .failure(.cantDecode)
        }
    }
}

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
            XCTAssertEqual(result.photo.count, 1)
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
        "https://www.flickr.com/services/rest/?api_key=6ee86dfd9bce6f402e171ff247753cbd&format=json&method=flickr.photos.getPopular&user_id=\(userId)"
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
                "isfamily": 0
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
                "isfamily": 0
              }
            ]
          },
          "stat": "ok"
        }
        """.utf8)
    }
}


extension Flickr.Error: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.cantDecode, .cantDecode): return true
        default: return false
        }
    }
}
