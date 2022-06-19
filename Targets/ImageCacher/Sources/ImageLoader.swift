//
//  ImageLoader.swift
//  ImageCacher
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation

public protocol ImageLoader {
    func load(from url: URL) async throws -> Data
}
