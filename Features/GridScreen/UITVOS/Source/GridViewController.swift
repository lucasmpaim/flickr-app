
import Foundation
import UIKit
import GridScreen

public enum GridState {
    case empty(String), idle, loading, infiniteLoading
}

public struct GridCellViewModel {
    public init(title: String, owner: String, date: String, thumbnailImageURI: URL) {
        self.title = title
        self.owner = owner
        self.date = date
        self.thumbnailImageURI = thumbnailImageURI
    }
    
    public let title: String
    public let owner: String
    public let date: String?
    public let thumbnailImageURI: URL
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
    private var adapter: GridAdapter<GridCellViewModel>
    
    private var currentState: GridState = .loading
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(GridCell.self)
        collection.register(LoadingCell.self)
        return collection
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width / 3) - 180
        let height = width * 0.8
        flowLayout.itemSize = .init(width: width, height: height)
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

public final class GridCell: UICollectionViewCell, Reusable {
    //MARK: Types
    typealias ImageDownloadTaskProvider = (URL) -> Task<Data, Error>
    
    //MARK: - Views
    lazy var imageView = UIImageView()
    lazy var title = UILabel()
    
    
    //MARK: - Properties
    var imageDownloaderTask: Task<Void, Error>?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloaderTask?.cancel()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        additionalConfig()
    }
    
    func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        title.textColor = .white
        title.numberOfLines = .zero
        imageView.contentMode = .scaleAspectFill
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            title.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    func additionalConfig() {
        createGradientLayer()
    }
    
    // MARK: - Populate
    func populate(
        _ viewModel: GridCellViewModel,
        downloadTaskProvider: @escaping ImageDownloadTaskProvider
    ) {
        self.title.text = """
        \(viewModel.title)
        \(viewModel.owner) / \(viewModel.date ?? "")
        """
        self.imageView.image = nil // TODO: - Add Placeholder
        self.imageDownloaderTask = Task<Void, Error> { [weak self] in
            guard let self = self else { throw GeneralError.selfDetached }
            let result = await downloadTaskProvider(viewModel.thumbnailImageURI).getResult()
            guard !Task.isCancelled else { return }
            switch result {
            case .success(let data):
                await self.presentImage(data: data)
            case .failure(let error):
                debugPrint(error)
            }
            
            return ()
        }
    }
    
    @MainActor
    private func presentImage(data: Data) {
        imageView.image = UIImage(data: data)
    }
    
    public override func didUpdateFocus(
        in context: UIFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        
        coordinator.addCoordinatedAnimations({
            self.imageView.adjustsImageWhenAncestorFocused = self.isFocused
            self.contentView.transform = self.isFocused ? .init(scaleX: 1.05, y: 1.05) : .identity
        })

    }
    
    func createGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        self.imageView.layer.addSublayer(gradient)
    }
    
}

public final class LoadingCell: UICollectionViewCell, Reusable {
    
}


enum GeneralError : Error {
    case selfDetached
}
