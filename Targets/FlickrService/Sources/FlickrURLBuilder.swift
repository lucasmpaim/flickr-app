//
//  FlickrURLBuilder.swift
//  FlickrServiceTests
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation

final class FlickrURLBuilder {
    
    enum SupportedMethods {
        case fetchPopularPhotos
        case search(String)
        
        var name: String {
            switch self {
            case .fetchPopularPhotos: return "flickr.photos.getPopular"
            case .search: return "flickr.photos.search"
            }
        }
    }
    
    internal static var apiKey: String {
        "6ee86dfd9bce6f402e171ff247753cbd"
    }
    
    private static var baseURL: String {
        "https://www.flickr.com/services/rest/?api_key=\(apiKey)&format=json&extras=owner_name,date_upload&nojsoncallback=1"
    }
    
    private static var defaultUserNSId: String { "139356341@N05" }
    
    private let method: SupportedMethods
    
    private var userNSID: String?
    private var search: String?
    private var page: UInt = 1
    
    init(method: SupportedMethods) {
        self.method = method
    }
    
    func page(_ page: UInt) -> Self {
        self.page = page
        return self
    }
    
    func userId(_ id: String?) -> Self {
        self.userNSID = id
        return self
    }
    
    func build() -> URL? {
        let userIDString = encodeString(userNSID ?? FlickrURLBuilder.defaultUserNSId)
        var urlString = "\(FlickrURLBuilder.baseURL)&method=\(method.name)&user_id=\(userIDString)&page=\(page)"
        
        switch method {
        case .fetchPopularPhotos: break
        case .search(let search):
            urlString.append(contentsOf: "&text=\(encodeString(search))")
            break
        }
        
        return URL(string: urlString)
    }
    
    fileprivate func encodeString(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
}
