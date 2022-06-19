//
//  HttpClientTests.swift
//  HttpClientTests
//
//  Created by Lucas Paim on 18/06/22.
//

import XCTest

@testable import HttpClient

final class HttpClientTests: XCTestCase {
    
    func test_whenMakeASuccessfullRequest_shouldDecodeObjectCorretly() async {
        let sut = makeSUT()

        let urlToCall = anyURL()
        stubRequest(url: urlToCall, with: .init(statusCode: 200, data: .success(anyJson())))
        
        let result = await sut.getData(from: urlToCall)
        
        XCTAssertEqual(result, .success(anyJson()))
    }

    func test_whenMakeARequestWith4xxStatus_shouldThrowABadRequestError() async {
        let sut = makeSUT()
        let urlToCall = anyURL()
        stubRequest(url: urlToCall, with: .init(statusCode: 400, data: .success(anyJson())))
    
        let result = await sut.getData(from: urlToCall)
        XCTAssertEqual(result, .failure(.badRequest))
    }
    
    func test_whenMakeAFailureRequest_shouldThrowANetworkError() async {
        let sut = makeSUT()
        let urlToCall = anyURL()
        stubRequest(url: urlToCall, with: .init(statusCode: 400, data: .failure(Error.anyError)))
    
        let result = await sut.getData(from: urlToCall)
        XCTAssertEqual(result, .failure(.networkError))
    }
    
}

// MARK: - Helpers

extension HTTP.ClientError : Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.badRequest, .badRequest): return true
            case (.networkError, .networkError): return true
            default: return false
        }
    }
}

fileprivate extension HttpClientTests {
    enum Error: Swift.Error {
        case anyError
    }
    
    func anyJson() -> Data {
        Data(
            """
            {"name": "Teste"}
            """.utf8
        )
    }
    
    func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        startInterceptingRequests(on: configuration)
        return URLSessionHTTPClient(session: .init(configuration: configuration))
    }
    
    func anyURL() -> URL {
        return URL(string: "https://google.com")!
    }
    
}
