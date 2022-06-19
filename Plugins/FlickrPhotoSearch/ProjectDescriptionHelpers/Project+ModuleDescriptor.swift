//
//  Project+ModuleDescriptor.swift
//  FlikrPhotoPlugin
//
//  Created by Lucas Paim on 19/06/22.
//

import Foundation
import ProjectDescription


public struct ModuleDescriptor {

    public typealias BundleFactory = (String) -> String
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
        from descriptor: ModuleDescriptor
    ) -> [Target] {
        return [
            Target(
                name: descriptor.name,
              platform: .tvOS,
              product: .framework,
              bundleId: descriptor.bundle(descriptor.name),
              sources: "Feature/Source/**/*.swift",
              dependencies: descriptor.dependencies,
              settings: .makeSharedLibrarySettings()
            ),
            Target(
              name: descriptor.name.appending("Tests"),
              platform: .tvOS,
              product: .unitTests,
              bundleId: descriptor.bundle(descriptor.name),
              sources: "Feature/Tests/**/*.swift",
              dependencies: [
                .xctest,
                .target(name: descriptor.name)
              ],
              settings: .makeSharedLibrarySettings()
            ),
            Target(
                name: descriptor.name.appending("UITVOS"),
                platform: .tvOS,
                product: .framework,
                bundleId: descriptor.bundle(descriptor.name.appending("UITVOS")),
                sources: "UITVOS/Source/**/*.swift",
                dependencies: [
                    .target(name: descriptor.name)
                ]
            ),
            Target(
                name: descriptor.name.appending("Sample"),
                platform: .tvOS,
                product: .framework,
                bundleId: descriptor.bundle(descriptor.name.appending("Sample")),
                sources: "Sample/Source/**/*.swift",
                resources: "Sample/Resource/**",
                dependencies: [
                    .target(name: descriptor.name),
                    .target(name: descriptor.name.appending("UITVOS"))
                ]
            ),
        ]
    }
}

public extension Project {
    static func appModule(from descriptor: ModuleDescriptor) -> Self {
        return Project(
            name: descriptor.name,
            settings: .makeModuleSettings(),
            targets: Target.targets(from: descriptor)
        )
    }
}
