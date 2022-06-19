//
//  GridCellViewModel.swift
//  GridScreen
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

public struct GridCellViewModel {
    public init(title: String, owner: String, date: String, thumbnailImageURI: URL) {
        self.title = title
        self.owner = owner
        self.date = date
        self.thumbnailImageURI = thumbnailImageURI
    }
    
    public let title: String
    public let owner: String
    public let date: String?
    public let thumbnailImageURI: URL
}
