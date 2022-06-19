//
//  GridCell.swift
//  GridScreen
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit


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
            
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15),
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
