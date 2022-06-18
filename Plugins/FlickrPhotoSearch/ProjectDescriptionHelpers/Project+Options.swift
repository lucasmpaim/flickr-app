//
//  Project+Options.swift
//  MyPlugin
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import ProjectDescription

extension Project.Options.TextSettings {

    static var appTextOptions: Project.Options.TextSettings {
        .textSettings(
            usesTabs: false,
            indentWidth: 4,
            tabWidth: 4,
            wrapsLines: true
        )
    }

}

public extension Project.Options {
    static var appOptions: Project.Options {
        .options(
            automaticSchemesOptions: .enabled(
                targetSchemesGrouping: .singleScheme,
                codeCoverageEnabled: true,
                testingOptions: [
                    .parallelizable,
                    .randomExecutionOrdering
                ]
            ),
            developmentRegion: "en_US",
            disableBundleAccessors: true,
            disableShowEnvironmentVarsInScriptPhases: false,
            disableSynthesizedResourceAccessors: true,
            textSettings: .appTextOptions
        )
    }
}
