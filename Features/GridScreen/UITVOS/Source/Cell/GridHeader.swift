//
//  GridHeader.swift
//  GridScreenUITVOS
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import UIKit


public final class GridHeader: UICollectionReusableView, Reusable {
    
    //MARK: - Views
    lazy var title = UILabel()
    
    
    //MARK: - Properties
    public required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        title.textColor = .white
        title.numberOfLines = .zero
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 15),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            title.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        ])
    }
    
    
    // MARK: - Populate
    func populate(
        _ viewModel: String
    ) {
        self.title.text = viewModel
    }
    
    
}
