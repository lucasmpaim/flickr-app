//
//  Project+Settings.swift
//  MyPlugin
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import ProjectDescription

public extension Configuration {
    static var allSupportedConfigurations: [Configuration] = [
        .debug(name: "Debug"), .release(name: "Release")
    ]
}

public extension Settings {
    
    static func makeAppSettings() -> Settings {
        let base: SettingsDictionary = [
            "EMBEDDED_CONTENT_CONTAINS_SWIFT": true,
        ]
        return Settings.settings(
            base: base,
            configurations: Configuration.allSupportedConfigurations
        )
    }
    
    static var test: Settings {
        let base: SettingsDictionary = [
            "BUNDLER_LOADER": "$(BUILT_PRODUCTS_DIR)/$(PRODUCT_NAME).app/"
        ]
        return Settings.settings(base: base, configurations: [.debug(name: "Debug")])
    }
    
    static func makeSharedLibrarySettings() -> Settings {
        let base: SettingsDictionary = [
            "EMBEDDED_CONTENT_CONTAINS_SWIFT": false,
            "FRAMEWORK_SEARCH_PATHS": "$(inherited) $(SYMROOT)/Release$(EFFECTIVE_PLATFORM_NAME)"
        ]
        return Settings.settings(
            base: base,
            configurations: Configuration.allSupportedConfigurations
        )
    }
    
}
