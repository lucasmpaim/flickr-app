//
//  FlickrURLBuilder.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation

struct FlickrURLBuilder {
    
    enum SupportedMethods: String, RawRepresentable {
        case fetchPopularPhotos = "flickr.photos.getPopular"
    }
    
    private static var apiKey: String {
        "6ee86dfd9bce6f402e171ff247753cbd"
    }
    
    private static var baseURL: String {
        "https://www.flickr.com/services/rest/?api_key=\(apiKey)&format=json"
    }
    
    private static var defaultUserNSId: String { "139356341@N05" }
    
    private let method: SupportedMethods
    private var userNSID: String?
    
    init(method: SupportedMethods) {
        self.method = method
    }
    
    mutating func userId(_ id: String) -> Self {
        self.userNSID = id
        return self
    }
    
    func build() -> URL? {
        let userIDString = (userNSID ?? FlickrURLBuilder.defaultUserNSId).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let urlString = "\(FlickrURLBuilder.baseURL)&method=\(method.rawValue)&user_id=\(userIDString)"
        return URL(string: urlString)
    }
    
}
