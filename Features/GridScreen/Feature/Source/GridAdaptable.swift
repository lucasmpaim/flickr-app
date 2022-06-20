import Foundation


public typealias ReloadAction = () -> Void

public protocol GridAdaptable : AnyObject {
    associatedtype Item
    
    var reloadAction: ReloadAction { get set }
    
    func set(items: [Item])
    func append(items: [Item])
    
    func itemFor(index: UInt) -> Item
    
    func countItems() -> Int

}
