//
//  FlickrServiceTests.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 18/06/22.
//

import XCTest
@testable import FlickrService

//protocol FlickrService {
//    func
//}

struct RemotePage<T: Decodable>: Decodable {
    let page: UInt
    let pages: UInt
    let perpage: UInt
    let total: UInt
}

struct RemotoPhoto: Decodable {
    let id: String
    let secret: String
    let isPublic: Bool
    let title: String
}

struct RemoteResponseMapper {
    static func 
}

final class FlickrServiceTests: XCTestCase {
    
}
