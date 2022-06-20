//
//  FetchPagedSearchFlickrPhotosUseCase.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 20/06/22.
//

import Foundation
import FlickrService

protocol PagedSearchFlickrPhotosUseCaseFetchable {
    func execute(
        page: UInt,
        search: String,
        completion: @escaping @MainActor (Result<(Bool, [Photo]), Error>) -> Void
    )
}

final class FetchPagedSearchFlickrPhotosUseCase: PagedSearchFlickrPhotosUseCaseFetchable {
    
    private let service: FlickrService
    init(service: FlickrService) {
        self.service = service
    }
    
    func execute(
        page: UInt,
        search string: String,
        completion: @escaping @MainActor (Result<(Bool, [Photo]), Error>) -> Void
    ) {
        Task {
            let result = await service.search(userID: nil, search: string, page: page)
            switch result {
            case .success(let paged):
                await completion(.success((paged.photos.count >= paged.perPage, paged.photos)))
            case .failure(let error):
                await completion(.failure(error))
            }
        }
    }
}
