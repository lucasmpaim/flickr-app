//
//  GridView.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 20/06/22.
//

import Foundation
import UIKit

protocol GridViewDelegate: AnyObject {
    func reloadData()
    func setGridContentProvider(
        _ provider: UICollectionViewDataSource & UICollectionViewDelegate
    )
}

final class GridView: UIView, GridViewDelegate {
    
    //MARK: - Views
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.register(GridCell.self)
        collection.register(LoadingCell.self)
        collection.register(GridHeader.self)
        return collection
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width / 3) - 180
        let height = width * 0.8
        flowLayout.itemSize = .init(width: width, height: height)
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 80)
        flowLayout.sectionInset = .init(top: 80, left: 0, bottom: 0, right: 0)
        return flowLayout
    }()
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func setGridContentProvider(_ provider: UICollectionViewDataSource & UICollectionViewDelegate) {
        collectionView.delegate = provider
        collectionView.dataSource = provider
        collectionView.reloadData()
    }
}
