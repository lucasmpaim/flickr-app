//
//  GridViewControllerViewModel.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import GridScreen

public protocol GridViewControllerViewModel {
    associatedtype GridAdaptable: GridScreen.GridAdaptable
        where GridAdaptable.Item == GridCellViewModel
    
    func loadImage(url: URL) async throws -> Data
    
    var observeState: ((GridState) -> Void)? { get set }
    var currentState: GridState { get }
    
    var adapter: GridAdaptable { get }
    
    func startFetchingData()
}

