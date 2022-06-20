//
//  FlickrTrandingTopGridViewModel.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 20/06/22.
//

import Foundation
import GridScreen
import GridScreenUITVOS
import FlickrService

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


fileprivate extension Photo {
    func toGridCellViewModel() -> GridCellViewModel {
        return .init(
            title: self.title,
            owner: self.ownerName,
            date: "",
            thumbnailImageURI: URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
        )
    }
}
