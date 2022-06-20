//
//  FlickrSearchCoordinator.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit

final class FlickrSearchCoordinator {
    
    func rootViewController() -> UIViewController {
        let tabController = UITabBarController()
        let searchController = UISearchContainerViewController(
            searchController: UISearchController()
        )
        searchController.title = "Search"
        tabController.viewControllers = [
            FlickrTradingTopRoute.makeViewController(),
            searchController
        ]
        return tabController
    }
    
//    func enterOnSearch() -> UIViewController { }
    
}
