//
//  FlickrURLBuilderTests.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import XCTest
@testable import FlickrService

final class FlickrURLBuilderTests: XCTestCase {
    func test_whenCreateFlickrURL_withPopularPhotos_shouldReturnSameURLFromExplorer() {
        let sut = FlickrURLBuilder(method: .fetchPopularPhotos)
        let url = sut.build()
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.relativeString, anyFlickrURL())
    }
    
    func test_whenCreateFlickrURLAndPassACustomUserId_shouldCreateURLCorrectly() {
        var sut = FlickrURLBuilder(method: .fetchPopularPhotos)
        let url = sut.userId("someId").build()
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.relativeString, anyFlickrURL(userId: "someId"))
    }
    
    func test_whenCreateSearchFlickrURL_shouldCreateURLCorrectly() {
        var sut = FlickrURLBuilder(method: .search("test"))
        let url = sut.build()
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.relativeString, anySearchFlickrURL(search: "test"))
    }
}

fileprivate extension FlickrURLBuilderTests {
    func anyFlickrURL(userId: String = "139356341%40N05") -> String {
        "https://www.flickr.com/services/rest/?api_key=\(FlickrURLBuilder.apiKey)&format=json&extras=owner_name,date_upload&nojsoncallback=1&method=flickr.photos.getPopular&user_id=\(userId)&page=1"
    }
    
    func anySearchFlickrURL(userId: String = "139356341%40N05", search string: String) -> String {
        "https://www.flickr.com/services/rest/?api_key=\(FlickrURLBuilder.apiKey)&format=json&extras=owner_name,date_upload&nojsoncallback=1&method=flickr.photos.search&user_id=\(userId)&page=1&text=\(string)"
    }
}

