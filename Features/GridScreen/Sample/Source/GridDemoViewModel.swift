//
//  GridDemoViewModel.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import GridScreen
import GridScreenUITVOS

final class GridDemoViewModel: GridViewControllerViewModel {
    typealias GridAdapter = GridScreen.GridAdapter<GridCellViewModel>
    
    public let adapter: GridScreen.GridAdapter<GridCellViewModel>
    
    init(adapter: GridScreen.GridAdapter<GridCellViewModel>) {
        self.adapter = adapter
    }
    
    func startFetchingData() {
        adapter.set(items: DemoItemsProvider.items)
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
