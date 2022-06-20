
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


public final class GridViewController<VM: GridViewControllerViewModel>:
    UIViewController, GridRender, UICollectionViewDataSource, UICollectionViewDelegate {
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public weak var delegate: GridDelegate?
    
    var adapter: VM.GridAdaptable { viewModel.adapter }
        
    private var viewModel: VM
    
    private let screenTitle: String
    
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
        viewModel: VM,
        screenTitle: String
    ) {
        self.delegate = delegate
        self.viewModel = viewModel
        self.screenTitle = screenTitle
        
        super.init(nibName: nil, bundle: nil)
        
        self.adapter.reloadAction = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        self.viewModel.observeState = { [weak self] state in
            self?.render(state: state)
        }
        
        setupViews()
        setupConstraints()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startFetchingData()
    }
    
    public func render(state: GridState) {

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
                    return try await self.viewModel.loadImage(url: url)
                }
            }
        )
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return .init() }
        let cell = collectionView.dequeue(GridHeader.self, for: indexPath)
        switch viewModel.currentState {
        case .empty(let customTitle): cell.title.text = customTitle
        default: cell.title.text = screenTitle
        }
        return cell
    }
    
}



enum GeneralError : Error {
    case selfDetached
}
