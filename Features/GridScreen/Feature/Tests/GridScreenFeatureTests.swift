
@testable import GridScreen
import XCTest
import ImageCacher




final class GridScreenFeatureTests: XCTestCase {
    func test_whenSetItemsReloadAction_shouldBeCalled() {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .success(anyData())))
        sut.reloadAction = {
            reloadActionCount += 1
        }
        
        sut.set(items: [1, 2, 3])
        
        XCTAssertEqual(reloadActionCount, 1)
    }
    
    func test_whenAppendItemsReloadAction_shouldBeCalled() {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .success(anyData())))
        sut.reloadAction = {
            reloadActionCount += 1
        }
        
        sut.append(items: [1, 2, 3])
        
        XCTAssertEqual(reloadActionCount, 1)
    }
    
    func test_whenAskForImage_shouldReturnACorrectDataAndNotCallReloadAction() async throws {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .success(anyData())))
        sut.reloadAction = {
            reloadActionCount += 1
        }
        
        let data = try await sut.loadImage(url: anyURL())
        XCTAssertEqual(data, anyData())
        XCTAssertEqual(reloadActionCount, 0)
    }
    
    func test_whenAskForImageWithError_shouldThrowsCorrectErrror() async throws {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .failure(MockError.anyError)))
        sut.reloadAction = {
            reloadActionCount += 1
        }
        
        do {
            let data = try await sut.loadImage(url: anyURL())
            XCTFail("Expected to receive an error, got \(data) instead")
        } catch let error as MockError {
            XCTAssertEqual(error, .anyError)
        } catch let error {
            XCTFail("Expected to receive MockError.anyError, got \(error) instead")
        }
        XCTAssertEqual(reloadActionCount, 0)
    }
    
}

//MARK: - Helpers

fileprivate extension GridScreenFeatureTests {
    enum MockError: Error, Equatable {
        case anyError
    }
    
    final class ImageLoaderSpy: ImageLoader {
        
        private let mock: Result<Data, Error>
        
        init(mock: Result<Data, Error>) {
            self.mock = mock
        }
        
        private var loadMessages: [URL] = []
        func load(from url: URL) async throws -> Data {
            loadMessages.append(url)
            switch mock {
            case .success(let data): return data
            case .failure(let error): throw error
            }
        }
    }
    
    func anyData() -> Data {
        Data("".utf8)
    }
    
    func anyURL() -> URL {
        URL(string: "https://google.com")!
    }
}
