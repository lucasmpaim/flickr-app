//
//  GridDemoViewModel.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import ImageCacher
import GridScreen
import GridScreenUITVOS

final class GridDemoViewModel: GridViewControllerViewModel {
    
    var observeState: ((GridState) -> Void)?
    
    var currentState: GridState = .loading
    
    typealias GridAdapter = GridScreen.GridAdapter<GridCellViewModel>
    
    public let adapter: GridScreen.GridAdapter<GridCellViewModel>
    private let imageLoader: ImageLoader
    
    init(
        adapter: GridScreen.GridAdapter<GridCellViewModel>,
        imageLoader: ImageLoader
    ) {
        self.adapter = adapter
        self.imageLoader = imageLoader
    }
    
    func startFetchingData() {
        adapter.set(items: DemoItemsProvider.items)
    }
    
    func loadImage(url: URL) async throws -> Data {
        try await imageLoader.load(from: url)
    }
    
}


/*
 GridAdapter<GridCellViewModel>(
     imageLoader: SmartImageLoader(
         remoteLoader: .init(
             httpClient: URLSessionHTTPClient(session: .shared)
         ),
         cacheLoader: .init()
     )
 )
 */
