//
//  StubURL.swift
//  HttpClient
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import UIKit
import XCTest

public final class StubURLProtocol: URLProtocol {
    
    public typealias NetworkResult = Result<Data, Error>
    
    public struct Stub {
        let statusCode: UInt
        let data: NetworkResult
        
        public init(statusCode: UInt, data: StubURLProtocol.NetworkResult) {
            self.statusCode = statusCode
            self.data = data
        }
    }
    
    private static var mocks: [URL: Stub] = [:]

    class func stub(url: URL, with data: Stub) {
        StubURLProtocol.mocks[url] = data
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url, StubURLProtocol.mocks[url] != nil else {
            fatalError("One test is trying to hit the network with request: \(request)")
        }
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        guard let url = request.url, let stub = StubURLProtocol.mocks[url] else { return }
        
        let urlResponse: HTTPURLResponse = .init(
            url: url,
            statusCode: Int(stub.statusCode),
            httpVersion: nil,
            headerFields: [:]
        )!
        
        client?.urlProtocol(
            self,
            didReceive: urlResponse,
            cacheStoragePolicy: .notAllowed
        )
        
        switch stub.data {
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let data):
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    public override func stopLoading() {}

}

public extension XCTestCase {
    
    func startInterceptingRequests(on session: URLSessionConfiguration) {
        session.protocolClasses?.insert(StubURLProtocol.self, at: .zero)
    }
    
    func stopInterceptingRequests(on session: URLSessionConfiguration) {
        session.protocolClasses?.removeAll(
            where: { $0 == StubURLProtocol.self }
        )
    }

    func stubRequest(url: URL, with data: StubURLProtocol.Stub) {
        StubURLProtocol.stub(url: url, with: data)
    }

}
