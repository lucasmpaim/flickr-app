//
//  ImageSaver.swift
//  ImageCacher
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

public protocol ImageSaver {
    func save(data: Data, from url: URL) async
    func fileExists(from url: URL) -> Bool
}
