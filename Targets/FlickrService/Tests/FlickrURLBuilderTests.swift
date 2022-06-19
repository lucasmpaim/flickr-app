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
    func test_whenCreateFlickrURL_withPopularPhotosShouldReturnSameURLFromExplorer() {
        let sut = FlickrURLBuilder(method: .fetchPopularPhotos)
        let url = sut.build()
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.relativeString, anyFlickrURL())
    }
    
    func test_whenCreateFlickrURLAndPassACustomUserId_ShouldCreateURLCorrectly() {
        var sut = FlickrURLBuilder(method: .fetchPopularPhotos)
        let url = sut.userId("someId").build()
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.relativeString, anyFlickrURL(userId: "someId"))
    }
}

fileprivate extension FlickrURLBuilderTests {
    func anyFlickrURL(userId: String = "139356341%40N05") -> String {
        "https://www.flickr.com/services/rest/?api_key=6ee86dfd9bce6f402e171ff247753cbd&format=json&extras=owner_name,dateupload&method=flickr.photos.getPopular&user_id=\(userId)"
    }
}

