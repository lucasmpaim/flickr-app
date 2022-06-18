import Foundation
import ProjectDescription

public extension DeploymentTarget {
    static let iOSVersion: Self = .iOS(
        targetVersion: "14.0",
        devices: [.iphone, .ipad]
    )
    
    static let tvOSVersion: Self = .tvOS(
        targetVersion: "14.0"
    )
}
