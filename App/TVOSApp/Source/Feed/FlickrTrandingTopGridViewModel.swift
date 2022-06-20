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
    
    // MARK: - Types
    typealias GridAdapter = GridScreen.GridAdapter<GridCellViewModel>

    enum ApiMode: Equatable {
        case popular, search(String)
    }
    
    // MARK: - Observables Properties
    var observeState: ((GridState) -> Void)?
    var currentState: GridState = .idle {
        didSet {
            observeState?(currentState)
        }
    }
    
    var feedTitleObserver: ((String) -> Void)?
    var feedTitle: String = Constants.feedTitle {
        didSet {
            feedTitleObserver?(feedTitle)
        }
    }
    
    
    // MARK: - Properties
    var hasNextPage: Bool = true
    var currentPage: UInt = 1
    
    var currentMode: ApiMode = .popular {
        didSet {
            if currentMode != oldValue {
                cleanFeed()
                startFetchingData()
            }
        }
    }
    
    // MARK: - Dependencies
    public let adapter: GridScreen.GridAdapter<GridCellViewModel>
    public let searchPagedGridUseCase: PagedSearchFlickrPhotosUseCaseFetchable
    private let fetchPagedGridUseCase: PagedFlickrGridPhotosUseCaseFetchable
    private let imageUseCaseFetchable: ImageUseCaseFetchable
    
    init(
        adapter: GridScreen.GridAdapter<GridCellViewModel>,
        fetchPagedGridUseCase: PagedFlickrGridPhotosUseCaseFetchable,
        imageUseCaseFetchable: ImageUseCaseFetchable,
        searchPagedGridUseCase: PagedSearchFlickrPhotosUseCaseFetchable
    ) {
        self.adapter = adapter
        self.fetchPagedGridUseCase = fetchPagedGridUseCase
        self.imageUseCaseFetchable = imageUseCaseFetchable
        self.searchPagedGridUseCase = searchPagedGridUseCase
    }
    
    func startFetchingData() {
        currentPage = 1
        makeRequest()
    }
    
    func nextPage() {
        guard hasNextPage, currentState != .loading else { return }
        currentPage += 1
        makeRequest()
    }
    
    func retry() {
        makeRequest()
    }
    
    func search(_ string: String) {
        if string.isEmpty {
            currentMode = .popular
            return
        }
        currentMode = .search(string)
    }
    
    private func makeRequest() {
        switch currentMode {
        case .popular:
            fetchPopular(page: currentPage)
        case .search(let string):
            fetchSearch(page: currentPage, search: string)
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
        adapter.append(items: items)
    }
    
    func cleanFeed() {
        currentPage = 1
        hasNextPage = true
        adapter.set(items: [])
    }
}

fileprivate extension FlickrTrandingTopGridViewModel {
    enum Constants {
        static var feedTitle: String = "Tranding Now On Fickr"
        static var searchTitle: (String) -> String = { string in
            "Results search for \"\(string)\""
        }
        static var emptySearchTitle: (String) -> String = { string in
            "No search results for \"\(string)\""
        }
    }
}

fileprivate extension FlickrTrandingTopGridViewModel {
    func fetchPopular(page: UInt = 1) {
        guard currentState != .loading else { return }
        currentState = .loading
        self.feedTitle = Constants.feedTitle
        fetchPagedGridUseCase.execute(page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let hasNextPage, let photos)):
                self.currentState = page == 1 && photos.isEmpty ? .empty : .idle
                self.hasNextPage = hasNextPage
                self.displayItems(items: photos.map { $0.toGridCellViewModel() })
            case .failure(let error):
                self.currentState = .error
                debugPrint(error)
            }
        }
    }
    
    func fetchSearch(page: UInt = 1, search string: String) {
        guard currentState != .loading else { return }
        currentState = .loading

        searchPagedGridUseCase.execute(page: page, search: string) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let hasNextPage, let photos)):
                let isEmpty = page == 1 && photos.isEmpty
                self.hasNextPage = hasNextPage
                self.feedTitle = isEmpty ? Constants.emptySearchTitle(string) : Constants.searchTitle(string)
                self.currentState = isEmpty ? .empty : .idle
                self.displayItems(items: photos.map { $0.toGridCellViewModel() })
            case .failure(let error):
                self.currentState = .error
                debugPrint(error)
            }
        }
    }
}

fileprivate extension Photo {
    func toGridCellViewModel() -> GridCellViewModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        var date = ""
        if let uploadDate = dateUpload {
            date = dateFormatter.string(from: uploadDate)
        }
        return .init(
            title: self.title,
            owner: self.ownerName,
            date: date,
            thumbnailImageURI: URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
        )
    }
}
