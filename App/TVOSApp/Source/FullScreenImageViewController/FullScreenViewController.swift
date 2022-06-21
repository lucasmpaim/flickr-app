//
//  FullScreenViewController.swift
//  FlickrSearch
//
//  Created by Lucas Paim on 20/06/22.
//

import Foundation
import UIKit

protocol FullImageDisplayer : AnyObject {
    func displayImage(_ image: UIImage?)
}

final class FullImageScreenView: UIView, FullImageDisplayer {
    
    lazy var imageView = UIImageView()
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    
    func displayImage(_ image: UIImage?) {
        imageView.image = image
    }
}

final class FullImageScreenViewController: UIViewController {
    
    weak var imageDisplayer: FullImageDisplayer?
    
    override func loadView() {
        let view = FullImageScreenView()
        imageDisplayer = view
        self.view = view
    }
    
    private var images: [URL]
    private var fetchImageUseCase: ImageUseCaseFetchable
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(
        images: [URL],
        fetchImageUseCase: ImageUseCaseFetchable
    ) {
        self.images = images
        self.fetchImageUseCase = fetchImageUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = images.first else { return }
        loadImage(from: url)
    }
    
    func loadImage(from url: URL) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let data = try await self.fetchImageUseCase.execute(url: url)
                await self.displayImageData(data)
            } catch {
                await MainActor.run { [weak self] in
                    self?.displayDownloadError()
                }
            }
        }
    }
    
    @MainActor
    func displayImageData(_ data: Data) {
        
        guard let image = UIImage(data: data) else {
            imageDisplayer?.displayImage(nil)
            displayDownloadError()
            return
        }
        
        imageDisplayer?.displayImage(image)
    }
    
}


extension FullImageScreenViewController {
    func displayDownloadError() {
        let alert = UIAlertController(title: "Error", message: "Cant Display This Image", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .destructive, handler: { _ in  }))
        show(alert, sender: nil)
    }
}
