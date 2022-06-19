
import Foundation
import UIKit
import GridScreen

public enum GridState {
    case empty(String), idle, loading, infiniteLoading
}

public protocol GridRender {
    func render(state: GridState)
}

public protocol GridDelegate: AnyObject {
    func select(itemOn index: Int)
}


public final class GridViewController: UIViewController, GridRender {
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public weak var delegate: GridDelegate?
    
    var adapter: GridAdapter<GridCellViewModel>
    var currentState: GridState = .loading
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
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

    public init(
        delegate: GridDelegate,
        adapter: GridAdapter<GridCellViewModel>
    ) {
        self.delegate = delegate
        self.adapter = adapter
        super.init(nibName: nil, bundle: nil)
        
        self.adapter.reloadAction = {[weak self] in
            self?.collectionView.reloadData()
        }
        
        setupViews()
        setupConstraints()
    }
    
    public func render(state: GridState) {
        self.currentState = state
    }
    
    func setupViews() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    
}



enum GeneralError : Error {
    case selfDetached
}
