//
//  FetchPagedFlickrGridPhotosUseCase.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 20/06/22.
//

import Foundation
import FlickrService

protocol PagedFlickrGridPhotosUseCaseFetchable {
    func execute(
        page: UInt,
        completion: @escaping @MainActor (Result<(Bool, [Photo]), Error>) -> Void
    )
}

final class FetchPagedFlickrGridPhotosUseCase: PagedFlickrGridPhotosUseCaseFetchable {
    
    private let service: FlickrService
    init(service: FlickrService) {
        self.service = service
    }
    
    func execute(
        page: UInt,
        completion: @escaping @MainActor (Result<(Bool, [Photo]), Error>) -> Void
    ) {
        Task {
            let result = await service.fetchPopular(userID: nil)
            switch result {
            case .success(let paged):
                await completion(.success((paged.photos.count >= paged.perPage, paged.photos)))
            case .failure(let error):
                await completion(.failure(error))
            }
        }
    }
}
