//
//  ModuleDescriptor.swift
//  MyPlugin
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import ProjectDescription


public struct LibraryDescriptor {
    public typealias BundleFactory = (String, Platform) -> String
    public typealias NameFactory = (String, Platform) -> String
    public typealias TestsFactory = (String, Platform) -> String

    let name: String
    let testName: TestsFactory
    let bundle: BundleFactory
    let dependencies: [TargetDependency]
    
    public init(name: String,
                dependencies: [TargetDependency] = []
    ) {
        self.name = name
        self.dependencies = dependencies
        self.testName = { "\($0)\($1)Tests" }
        self.bundle = { "br.com.paim.Flickr.\($0)\($1)" }
    }
}


extension Target {
    static func targets(
        from descriptor: LibraryDescriptor,
        platform: Platform
    ) -> [Target] {
        let targetName = descriptor.name.appending("\(platform)")
        return [
            Target(
              name: targetName,
              platform: platform,
              product: .framework,
              bundleId: descriptor.bundle(descriptor.name, platform),
              sources: "Sources/**/*.swift"
            ),
            Target(
              name: targetName.appending("Tests"),
              platform: platform,
              product: .unitTests,
              bundleId: descriptor.bundle(descriptor.name, platform),
              sources: "Tests/**/*.swift",
              dependencies: [
                .xctest,
                .target(name: targetName)
              ]
            )
        ]
    }
}

public extension Project {
    static func sharedLibrary(from descriptor: LibraryDescriptor) -> Self {
        return Project(
            name: descriptor.name,
            settings: .makeSharedLibrarySettings(),
            targets: Target.targets(from: descriptor, platform: .iOS) + Target.targets(from: descriptor, platform: .tvOS)
        )
    }
}
