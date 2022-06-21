//
//  FlickrSearchCoordinator.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit
import HttpClient
import ImageCacher
import GridScreenUITVOS

final class FlickrSearchCoordinator: NSObject {
    
    private var debouncer = Debouncer(timeInterval: 3)
    
    func rootViewController() -> UIViewController {
        let tabController = UITabBarController()
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        let searchContainerController = UISearchContainerViewController(
            searchController: searchController
        )
        searchContainerController.title = "Search"
        
        tabController.viewControllers = [
            FlickrTradingTopRoute.makeViewController(),
            searchContainerController
        ]
        return tabController
    }
    
    func fullScreenImage(with url: URL) -> UIViewController {
        let controller = FullScreenViewControllerRoute.makeViewController(imageURL: [url])
        return controller
    }
    
}

final class FullScreenViewControllerRoute {
    static func makeViewController(imageURL: [URL]) -> UIViewController {
        let viewController = FullImageScreenViewController(
            images: imageURL,
            fetchImageUseCase: FetchImageUseCase(
                imageLoader: SmartImageLoader(
                    remoteLoader: .init(httpClient: URLSessionHTTPClient(session: .shared)),
                    cacheLoader: .init()
                )
            )
        )
        return viewController
    }
}

extension FlickrSearchCoordinator: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        debouncer.handler = { [weak searchController] in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let tabBar = appDelegate.window?.rootViewController as? UITabBarController,
                  let updatable = tabBar.viewControllers?.first as? SearchUpdatable else {
                return
            }
            updatable.setSearch(string: searchController?.searchBar.text ?? "")
        }
        debouncer.renewInterval()
    }
}

