import UIKit
import GridScreen
import XCTest
@testable import GridScreenUITVOS



public class GridViewTests: XCTestCase {

    func test_whenCellIsPreparedForReuseCantFinishTheTask() {
        let sut = GridCell(frame: .zero)
        let expectation = self.expectation(description: "wait task")
        
        sut.populate(
            anyGridCellViewModel()
        ) { url in
            Task {
                // wait one second
                try await Task.sleep(UInt64(1e+9))
                return self.anyImageData()
            }
        }
        Task {
            // wait two seconds
            try await Task.sleep(nanoseconds: UInt64(2e+9))
            expectation.fulfill()
        }
        sut.prepareForReuse()
        waitForExpectations(timeout: 3)
        XCTAssertNil(sut.imageView.image)
    }
    
    func test_anyImageDataShouldCreateUIImageWithoutProblems() {
        let sut = UIImage(data: anyImageData())
        XCTAssertNotNil(sut)
    }
    
    func anyGridCellViewModel() -> GridCellViewModel {
        return GridCellViewModel(
            title: "Test",
            thumbnailImageURI: URL(string: "https://google.com.br")!
        )
    }
    
    func anyImageData() -> Data { UIImage.add.pngData()! }
    
    enum TestError: Error {
        case anyError
    }
}

