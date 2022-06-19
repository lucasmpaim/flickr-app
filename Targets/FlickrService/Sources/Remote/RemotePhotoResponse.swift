//
//  RemotePhotoResponse.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

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
