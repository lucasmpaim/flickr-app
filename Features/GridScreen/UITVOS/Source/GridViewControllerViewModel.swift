//
//  GridViewControllerViewModel.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import GridScreen
import UIKit

public protocol GridViewControllerViewModel {
    associatedtype GridAdaptable: GridScreen.GridAdaptable
        where GridAdaptable.Item == GridCellViewModel
    
    func loadImage(url: URL) async throws -> Data
    
    var observeState: ((GridState) -> Void)? { get set }
    var currentState: GridState { get }
    
    var feedTitleObserver: ((String) -> Void)? { get set }
    var feedTitle: String { get }

    var adapter: GridAdaptable { get }
    
    func selectItemFromIndex(index: Int)
    
    func startFetchingData()
    
    func nextPage()
    func retry()
    
    
    var observeRoute: ((UIViewController) -> Void)? { get set }

}

