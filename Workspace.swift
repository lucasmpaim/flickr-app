//
//  Workspace.swift
//  FlickrPhotoSearchManifests
//
//  Created by Lucas Paim on 18/06/22.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(name: "FlickrApp", projects: [
    "Targets/HttpClient",
    "Targets/FlickrService",
    "Targets/ImageCacher",
    "Features/GridScreen"
])

