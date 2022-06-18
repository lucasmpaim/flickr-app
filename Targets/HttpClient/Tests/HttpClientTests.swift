//
//  HttpClientTests.swift
//  HttpClientTests
//
//  Created by Lucas Paim on 18/06/22.
//

import XCTest

#if os(iOS)
    @testable import HttpClientiOS
#else
    @testable import HttpClienttvOS
#endif


protocol APICredentialsProvider {
    
}

final class HTTPClient {
    
    enum ClientError: Error {
        case cantDecode, networkError, badRequest
    }
    
    private let session: URLSession
    
    init(session: URLSession)  {
        self.session = session
    }
    
    func getJSON<T : Decodable>(from url: URL, type: T.Type) async -> Result<T, ClientError> {
        do {
            let (data, urlResponse) = try await session.data(for: URLRequest(url: url))
            if let httpResposne = urlResponse as? HTTPURLResponse,
               httpResposne.statusCode < 200 || httpResposne.statusCode >= 300 {
                return .failure(.badRequest)
            }
            let entity = try JSONDecoder().decode(type, from: data)
            return .success(entity)
        } catch let error as DecodingError {
            debugPrint(error)
            return .failure(.cantDecode)
        } catch {
            return .failure(.networkError)
        }
    }
}


final class HttpClientTests: XCTestCase {
    
    func test_whenMakeASuccessfullRequest_shouldDecodeObjectCorretly() async {
        let sessionConfig: URLSessionConfiguration = .ephemeral
        startInterceptingRequests(on: sessionConfig)
        let sut = HTTPClient(session: .init(configuration: sessionConfig))
        let urlToCall = URL(string: "https://google.com")!
        stubRequest(url: urlToCall, with: .init(statusCode: 200, data: .success(anyJson())))
        
        let result = await sut.getJSON(from: urlToCall, type: CanDecode.self)
        
        XCTAssertEqual(result, .success(.init(name: "Teste")))
    }
    
    func test_whenMakeASuccessfullRequest_andReceivedAInvalid_shouldThrowACantDecodeError() async {
        let sessionConfig: URLSessionConfiguration = .ephemeral
        startInterceptingRequests(on: sessionConfig)
        let sut = HTTPClient(session: .init(configuration: sessionConfig))
        let urlToCall = URL(string: "https://google.com")!
        stubRequest(url: urlToCall, with: .init(statusCode: 200, data: .success(anyJson())))
        
        let result = await sut.getJSON(from: urlToCall, type: CantDecode.self)
        
        XCTAssertEqual(result, .failure(.cantDecode))
    }

    func test_whenMakeARequestWith4xxStatus_shouldThrowABadRequestError() async {
        let sessionConfig: URLSessionConfiguration = .ephemeral
        startInterceptingRequests(on: sessionConfig)
        let sut = HTTPClient(session: .init(configuration: sessionConfig))
        let urlToCall = URL(string: "https://google.com")!
        stubRequest(url: urlToCall, with: .init(statusCode: 400, data: .success(anyJson())))
        
        let result = await sut.getJSON(from: urlToCall, type: CanDecode.self)
        
        XCTAssertEqual(result, .failure(.badRequest))
    }
}

// MARK: - Helpers

extension HTTPClient.ClientError : Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.cantDecode, .cantDecode): return true
            case (.badRequest, .badRequest): return true
            default: return false
        }
    }
}

fileprivate extension HttpClientTests {
    enum Error: Swift.Error {
        case anyError
    }
    
    struct CanDecode: Equatable, Decodable {
        let name: String
    }
    struct CantDecode: Equatable, Decodable {
        let uName: String
    }
    
    func anyJson() -> Data {
        Data(
            """
            {"name": "Teste"}
            """.utf8
        )
    }
    
}
