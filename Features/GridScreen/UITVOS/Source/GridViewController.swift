
import Foundation
import UIKit
import GridScreen

public enum GridState: Equatable {
    case empty, idle, loading, error
}

public protocol GridRender {
    func render(state: GridState)
}

public final class GridViewController<VM: GridViewControllerViewModel>:
    UIViewController, GridRender, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    weak var gridViewDelegate: GridViewDelegate?
    
    var adapter: VM.GridAdaptable { viewModel.adapter }
    
    public var viewModel: VM
    
    public override func loadView() {
        let view = GridView()
        self.gridViewDelegate = view
        self.view = view
    }
    
    public init(
        viewModel: VM
    ) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.adapter.reloadAction = { [weak self] in
            self?.gridViewDelegate?.reloadData()
        }
        
        self.viewModel.observeState = { [weak self] state in
            self?.render(state: state)
        }
        
        self.viewModel.feedTitleObserver = { [weak self] _ in
            self?.gridViewDelegate?.reloadData()
        }
        
        self.viewModel.observeRoute = { [weak self] in
            self?.show($0, sender: nil)
        }
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startFetchingData()
        gridViewDelegate?.setGridContentProvider(self)
    }
    
    public func render(state: GridState) {
        switch state {
        case .empty: break
        case .idle: break
        case .loading: break
        case .error: displayError()
        }
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
        cell.title.text = viewModel.feedTitle
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.selectItemFromIndex(index: indexPath.row)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height * 0.7 {
            viewModel.nextPage()
        }
    }
}


extension GridViewController {
    func displayError() {
        let controller = UIAlertController(
            title: "One problem as ocurred",
            message: "Well... someone will take a look on it",
            preferredStyle: .alert
        )
        controller.addAction(.init(title: "Retry", style: .default, handler: { [weak self, weak controller] _ in
            controller?.dismiss(animated: true)
            self?.viewModel.retry()
        }))
        present(controller, animated: true)
    }
}

enum GeneralError : Error {
    case selfDetached
}
