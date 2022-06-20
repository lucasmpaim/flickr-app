//
//  FetchImageUseCase.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 20/06/22.
//

import Foundation
import ImageCacher

protocol ImageUseCaseFetchable {
    func execute(url: URL) async throws -> Data
}

final class FetchImageUseCase : ImageUseCaseFetchable {
    private let imageLoader: ImageLoader
    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }
    
    func execute(url: URL) async throws -> Data {
        return try await imageLoader.load(from: url)
    }
}
