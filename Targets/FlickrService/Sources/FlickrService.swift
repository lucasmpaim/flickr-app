//
//  FlickrService.swift
//  FlickrService
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import HttpClient

public protocol FlickrService {
    func fetchPopular(userID: String?) async -> Result<PhotoPage, Flickr.Error>
    func search(userID: String?, search: String) async -> Result<PhotoPage, Flickr.Error>
}

public struct FlickrServiceImpl : FlickrService {
    
    private let client: HTTPClient
    private let photoMapper: PagedPhotoMapper
    
    public init(
        client: HTTPClient,
        photoMapper: PagedPhotoMapper
    ) {
        self.client = client
        self.photoMapper = photoMapper
    }
    
    public func fetchPopular(userID: String? = nil) async -> Result<PhotoPage, Flickr.Error> {
        guard let url = FlickrURLBuilder(method: .fetchPopularPhotos)
            .userId(userID)
            .build() else { return .failure(.invalidURI) }
        
        let response = await client.getData(from: url)
        
        switch response {
        case .success(let data):
            return map(data: data)
        case .failure(let error):
            return .failure(.httpError(error))
        }
    }
    
    public func search(userID: String?, search string: String) async -> Result<PhotoPage, Flickr.Error> {
        
        guard let url = FlickrURLBuilder(method: .search(string))
            .userId(userID)
            .build() else { return .failure(.invalidURI) }
        
        let response = await client.getData(from: url)
        
        switch response {
        case .success(let data):
            return map(data: data)
        case .failure(let error):
            return .failure(.httpError(error))
        }
        
    }

    fileprivate func map(data: Data) -> Result<PhotoPage, Flickr.Error> {
        do {
            let result = try photoMapper.map(data)
            return .success(result)
        } catch let error {
            debugPrint(error)
            return .failure(.cantDecode)
        }
    }
}
