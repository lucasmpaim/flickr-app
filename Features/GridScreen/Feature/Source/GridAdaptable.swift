import Foundation


public typealias ReloadAction = () -> Void

public protocol GridAdaptable : AnyObject {
    associatedtype Item
    
    var reloadAction: ReloadAction { get }
    
    func set(items: [Item])
    func append(items: [Item])
    
    func itemFor(index: UInt) -> Item
    
    func loadImage(url: URL) async throws -> Data
    
    func countItems() -> Int
}
