import Foundation


public typealias ReloadAction = () -> Void

public protocol GridAdaptable {
    associatedtype Item
            
    func set(items: [Item])
    func append(items: [Item])
    
    func itemFor(index: UInt) -> Item
    
    func loadImage(url: URL) async throws -> Data
    
}
