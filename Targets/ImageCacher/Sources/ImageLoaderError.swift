//
//  ImageLoaderError.swift
//  ImageCacher
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import HttpClient

public enum ImageLoaderError: Error {
    case notFound, httpError(HTTP.ClientError)
}
