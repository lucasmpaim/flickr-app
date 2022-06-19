//
//  PagedPhotoMapperJsonDecoder.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

struct PagedPhotoMapperJsonDecoder : PagedPhotoMapper {
    func map(_ data: Data) throws -> PhotoPage {
        let wrapper = try JSONDecoder().decode(RemoteWrapper.self, from: data)
        return PhotoPage(remote: wrapper.photos)
    }
}
