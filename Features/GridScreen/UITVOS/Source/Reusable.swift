//
//  Reusable.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit

public protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    // https://forums.swift.org/t/relying-on-string-describing-to-get-the-name-of-a-type/16391
    static var reuseIdentifier: String { NSStringFromClass(self) }
}

// MARK: - Collection View convenience methods
public extension UICollectionView {

    /// Register an UICollectionViewCell to a UICollectionView.
    /// Be aware to use this only with viewcode type cells, this will not work properly with .xib and storyboard cells.
    ///
    func register<Cell>(_ cellType: Cell.Type) where Cell: UICollectionViewCell, Cell: Reusable {
        register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    /// Dequeue an UICollectionViewCell to a UICollectionView.
    /// Be aware to use this only with viewcode type cells, this will not work properly with .xib and storyboard cells.
    ///
    func dequeue<Cell>(_ cellType: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell, Cell: Reusable {
        // It's better to have the app crashing here. If we can't load the cell it means that we forgot to register it somewhere,
        // a regression test would catch this "problem" if the developer didn't found it yet. Worst case scenario it's better a
        // app crashing than an empty and useless list of nothing.
        return dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? Cell ?? Cell()
    }
    
    /// Register an UICollectionReusableView to a UICollectionView.
    /// Be aware to use this only with viewcode, this will not work properly with .xib and storyboard.
    ///
    func register<Cell>(
        _ cellType: Cell.Type,
        forSupplementaryViewOfKind kind: String = elementKindSectionHeader
    ) where Cell: UICollectionReusableView, Cell: Reusable {
        register(cellType, forSupplementaryViewOfKind: kind, withReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /// Dequeue an UICollectionReusableView to a UICollectionView.
    /// Be aware to use this only with viewcode, this will not work properly with .xib and storyboard.
    ///
    func dequeue<Cell>(
        _ cellType: Cell.Type,
        for indexPath: IndexPath,
        forSupplementaryViewOfKind kind: String = elementKindSectionHeader
    ) -> Cell where Cell: UICollectionReusableView, Cell: Reusable {
        // It's better to have the app crashing here. If we can't load the cell it means that we forgot to register it somewhere,
        // a regression test would catch this "problem" if the developer didn't found it yet. Worst case scenario it's better a
        // app crashing than an empty and useless list of nothing.
        return dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: cellType.reuseIdentifier,
            for: indexPath
        ) as? Cell ?? Cell()
    }

}
