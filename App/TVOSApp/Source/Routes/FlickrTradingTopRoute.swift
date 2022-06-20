//
//  FlickrTradingTopRoute.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit
import ImageCacher
import HttpClient
import GridScreen
import GridScreenUITVOS
import FlickrService


final class FlickrTradingTopRoute {
    static func makeViewController() -> UIViewController {
        let adapter = GridAdapter<GridCellViewModel>()
        
        let service = FlickrServiceImpl(
            client: URLSessionHTTPClient(session: .shared),
            photoMapper: PagedPhotoMapperJsonDecoder()
        )
        
        let grid = GridViewController(
            delegate: GridViewControllerDelegate(),
            viewModel: FlickrTrandingTopGridViewModel(
                adapter: adapter,
                fetchPagedGridUseCase: FetchPagedFlickrGridPhotosUseCase(service: service),
                imageUseCaseFetchable: FetchImageUseCase(
                    imageLoader: SmartImageLoader(
                        remoteLoader: .init(httpClient: URLSessionHTTPClient(session: .shared)),
                        cacheLoader: .init()
                    )
                )
            ),
            screenTitle: "Tranding Now On Fickr"
        )
        grid.title = "Feed"
        return grid
    }
}

fileprivate final class GridViewControllerDelegate: GridDelegate {
    func select(itemOn index: Int) { }
}

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

final class FlickrTrandingTopGridViewModel: GridViewControllerViewModel {
    var observeState: ((GridState) -> Void)?
    
    var currentState: GridState = .loading {
        didSet {
            observeState?(currentState)
        }
    }
    
    typealias GridAdapter = GridScreen.GridAdapter<GridCellViewModel>
    
    public let adapter: GridScreen.GridAdapter<GridCellViewModel>
    
    private let fetchPagedGridUseCase: PagedFlickrGridPhotosUseCaseFetchable
    private let imageUseCaseFetchable: ImageUseCaseFetchable
    
    init(
        adapter: GridScreen.GridAdapter<GridCellViewModel>,
        fetchPagedGridUseCase: PagedFlickrGridPhotosUseCaseFetchable,
        imageUseCaseFetchable: ImageUseCaseFetchable
    ) {
        self.adapter = adapter
        self.fetchPagedGridUseCase = fetchPagedGridUseCase
        self.imageUseCaseFetchable = imageUseCaseFetchable
    }
    
    func startFetchingData() {
        fetchPagedGridUseCase.execute(page: 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let hasNextPage, let photos)):
                self.displayItems(items: photos.map { $0.toGridCellViewModel() })
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func loadImage(url: URL) async throws -> Data {
        try await imageUseCaseFetchable.execute(url: url)
    }
    
    @MainActor
    fileprivate func updateCurrentState(newState: GridState) {
        currentState = newState
    }
    
    @MainActor
    func displayItems(items: [GridCellViewModel]) {
        adapter.set(items: items)
    }
}

extension Photo {
    func toGridCellViewModel() -> GridCellViewModel {
        return .init(
            title: self.title,
            owner: self.ownerName,
            date: "",
            thumbnailImageURI: URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
        )
    }
}
