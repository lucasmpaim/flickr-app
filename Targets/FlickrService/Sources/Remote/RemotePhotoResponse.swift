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
    let dateupload: String
    let ownername: String
}

extension Photo {
    init(remote: RemotePhoto) {
        self.init(
            id: remote.id,
            secret: remote.secret,
            isPublic: remote.ispublic == 1,
            title: remote.title,
            dateUpload: Date.fromFlickrDate(string: remote.dateupload),
            ownerName: remote.ownername
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

fileprivate extension Date {
    static func fromFlickrDate(string: String) -> Date? {
        guard let timeSince1970 = Double(string) else { return nil }
        return Date(timeIntervalSince1970: timeSince1970)
    }
}
