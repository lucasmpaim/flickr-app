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
import FlickrService
import GridScreenUITVOS


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
                ),
                searchPagedGridUseCase: FetchPagedSearchFlickrPhotosUseCase(
                    service: service
                )
            )
        )
        grid.title = "Feed"
        return grid
    }
}

fileprivate final class GridViewControllerDelegate: GridDelegate {
    func select(itemOn index: Int) { }
}


