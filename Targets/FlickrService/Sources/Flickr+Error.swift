//
//  Flickr+Error.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import HttpClient

public enum Flickr {
    
}

public extension Flickr {
    enum Error : Swift.Error {
        case httpError(HTTP.ClientError), invalidURI, cantDecode
    }
}
