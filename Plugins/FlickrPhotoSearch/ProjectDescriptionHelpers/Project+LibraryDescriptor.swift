//
//  ModuleDescriptor.swift
//  MyPlugin
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import ProjectDescription


public struct LibraryDescriptor {
    public typealias BundleFactory = (String) -> String
    public typealias NameFactory = (String) -> String
    public typealias TestsFactory = (String) -> String

    let name: String
    let testName: TestsFactory
    let bundle: BundleFactory
    let dependencies: [TargetDependency]
    
    
    public init(name: String,
                dependencies: [TargetDependency] = []
    ) {
        self.name = name
        self.dependencies = dependencies
        self.testName = { "\($0)Tests" }
        self.bundle = { "br.com.paim.Flickr.\($0)" }
    }
}


extension Target {
    static func targets(
        from descriptor: LibraryDescriptor
    ) -> [Target] {
        return [
            Target(
              name: descriptor.name,
              platform: .tvOS, /* override by settings, passed just for fill required argument  */
              product: .framework,
              bundleId: descriptor.bundle(descriptor.name),
              sources: "Sources/**/*.swift",
              settings: .makeSharedLibrarySettings()
            ),
            Target(
              name: descriptor.name.appending("Tests"),
              platform: .tvOS,
              product: .unitTests,
              bundleId: descriptor.bundle(descriptor.name),
              sources: "Tests/**/*.swift",
              dependencies: [
                .xctest,
                .target(name: descriptor.name)
              ],
              settings: .makeSharedLibrarySettings()
            )
        ]
    }
}

public extension Project {
    static func sharedLibrary(from descriptor: LibraryDescriptor) -> Self {
        return Project(
            name: descriptor.name,
            settings: .makeSharedLibrarySettings(),
            targets: Target.targets(from: descriptor)
        )
    }
}
