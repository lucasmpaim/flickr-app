//
//  PagedPhotoMapper.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

public protocol PagedPhotoMapper {
    func map(_ data: Data) throws -> PhotoPage
}
