//
//  ViewController.swift
//  FlickrPhotoSearch
//
//  Created by Lucas Paim on 17/06/22.
//

import UIKit
import Foundation
import GridScreen
import GridScreenUITVOS

final class DemoItemsProvider {
    
    static var size: String {
        let width = (UIScreen.main.bounds.width / 3) - 180
        let height = width * 0.8
        return "\(Int(width))/\(Int(height))"
    }
    
    static var randomId: String {
        String(Int.random(in: 0...1000))
    }
    
    static var items: [GridCellViewModel] = {
        var _items: [GridCellViewModel] = []
        for i in 0...200 {
            _items.append(
                GridCellViewModel(
                    title: "Some Image",
                    owner: "Some User",
                    date: "Mar 2022",
                    thumbnailImageURI: URL(string: "https://picsum.photos/id/\(randomId)/\(size)")!
                )
            )
        }
        return _items
    }()
}


final class DemoGridDelegate: GridDelegate {
    func select(itemOn index: Int) { }
}
