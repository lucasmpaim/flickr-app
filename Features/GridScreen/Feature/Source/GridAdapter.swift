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
    private let imageLoader: ImageLoader
    
    public init(
        items: [T] = [],
        imageLoader: ImageLoader
    ) {
        self.items = items
        self.imageLoader = imageLoader
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
    
    public func loadImage(url: URL) async throws -> Data {
        try await imageLoader.load(from: url)
    }
}
