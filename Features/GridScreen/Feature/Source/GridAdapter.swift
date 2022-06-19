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
    
    public let reloadAction: ReloadAction
    
    private var items: [T]
    private let imageLoader: ImageLoader
    
    public init(
        items: [T] = [],
        imageLoader: ImageLoader,
        reloadAction: @escaping ReloadAction
    ) {
        self.items = items
        self.imageLoader = imageLoader
        self.reloadAction = reloadAction
    }
    
    public func set(items: [T]) {
        self.items = items
        reloadAction()
    }
    
    public func append(items: [T]) {
        self.items.append(contentsOf: items)
        reloadAction()
    }
    
    public func itemFor(index: UInt) -> T {
        return items[Int(index)]
    }
    
    public func loadImage(url: URL) async throws -> Data {
        try await imageLoader.load(from: url)
    }
}
