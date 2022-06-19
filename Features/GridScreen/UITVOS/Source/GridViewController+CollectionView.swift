//
//  GridViewController+CollectionView.swift
//  GridScreen
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit

extension GridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adapter.countItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(GridCell.self, for: indexPath)
        cell.populate(
            adapter.itemFor(index: UInt(indexPath.row)),
            downloadTaskProvider: {
                url in Task<Data, Error> { [weak self] in
                    guard let self = self else { throw GeneralError.selfDetached }
                    return try await self.adapter.loadImage(url: url)
                }
            }
        )
        return cell
    }
}
