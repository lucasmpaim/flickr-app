
@testable import GridScreen
import XCTest
import ImageCacher

typealias ReloadAction = () -> Void

protocol GridAdaptable {
    associatedtype Item
    
    var reloadAction: ReloadAction { get }
        
    func set(items: [Item])
    func append(items: [Item])
    
    func itemFor(index: UInt) -> Item
    
    func loadImage(url: URL) async throws -> Data
    
}

final class GridAdapter<T> : GridAdaptable {
    
    typealias Item = T
    
    let reloadAction: ReloadAction
    
    private var items: [T]
    private let imageLoader: ImageLoader
    
    public init(
        items: [T] = [],
        imageLoader: ImageLoader,
        reloadAction: @escaping ReloadAction
    ) {
        self.items = items
        self.imageLoader = imageLoader
        self.reloadAction = reloadAction
    }
    
    func set(items: [T]) {
        self.items = items
        reloadAction()
    }
    
    func append(items: [T]) {
        self.items.append(contentsOf: items)
        reloadAction()
    }
    
    func itemFor(index: UInt) -> T {
        return items[Int(index)]
    }
    
    func loadImage(url: URL) async throws -> Data {
        try await imageLoader.load(from: url)
    }
}

final class GridScreenFeatureTests: XCTestCase {
    func test_whenSetItemsReloadAction_shouldBeCalled() {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .success(anyData())), reloadAction: {
            reloadActionCount += 1
        })
        
        sut.set(items: [1, 2, 3])
        
        XCTAssertEqual(reloadActionCount, 1)
    }
    
    func test_whenAppendItemsReloadAction_shouldBeCalled() {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .success(anyData())), reloadAction: {
            reloadActionCount += 1
        })
        
        sut.append(items: [1, 2, 3])
        
        XCTAssertEqual(reloadActionCount, 1)
    }
    
    func test_whenAskForImage_shouldReturnACorrectDataAndNotCallReloadAction() async throws {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .success(anyData())), reloadAction: {
            reloadActionCount += 1
        })
        
        let data = try await sut.loadImage(url: anyURL())
        XCTAssertEqual(data, anyData())
        XCTAssertEqual(reloadActionCount, 0)
    }
    
    func test_whenAskForImageWithError_shouldThrowsCorrectErrror() async throws {
        var reloadActionCount: Int = 0
        let sut = GridAdapter<Int>(imageLoader: ImageLoaderSpy(mock: .failure(MockError.anyError)), reloadAction: {
            reloadActionCount += 1
        })
        
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
