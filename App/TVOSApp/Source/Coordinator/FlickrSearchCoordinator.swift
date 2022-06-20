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
        tabController.viewControllers = [
            FlickrTradingTopRoute.makeViewController()
        ]
        return tabController
    }
    
//    func enterOnSearch() -> UIViewController { }
    
}
