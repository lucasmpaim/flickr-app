//
//  GridAdapter.swift
//  GridScreen
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import ImageCacher

public final class GridAdapter<T> : GridAdaptable {
    
    public typealias Item = T
    
    public var reloadAction: ReloadAction
    
    private var items: [T] {
        didSet {
            reloadAction()
        }
    }
    
    public init(
        items: [T] = []
    ) {
        self.items = items
        self.reloadAction = {}
    }
    
    public func set(items: [T]) {
        self.items = items
    }
    
    public func append(items: [T]) {
        self.items.append(contentsOf: items)
    }
    
    public func itemFor(index: UInt) -> T {
        return items[Int(index)]
    }
    
    public func countItems() -> Int {
        return items.count
    }
    
}
