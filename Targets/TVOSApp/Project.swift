import ProjectDescription
import ProjectDescriptionHelpers
import FlikrPhotoPlugin

let project = Project(
    name: "TVOSApp",
    settings: .makeAppSettings(),
    targets: [
        Target(
            name: "FlickrSearch",
            platform: .tvOS,
            product: .app,
            bundleId: "br.com.paim.FlickrSearch",
            sources: ["Source/**/*.swift"],
            resources: ["Resources/**/*"],
            dependencies: [
                .project(target: "HttpClient", path: .relativeToRoot("Targets/HttpClient")),
                .project(target: "ImageCacher", path: .relativeToRoot("Targets/ImageCacher")),
                .project(target: "FlickrService", path: .relativeToRoot("Targets/FlickrService")),
                .project(target: "GridScreen", path: .relativeToRoot("Features/GridScreen"))
            ]
        ),
        Target(
            name: "FlickrSearchTests",
            platform: .tvOS,
            product: .unitTests,
            bundleId: "br.com.paim.FlickrSearchTests",
            sources: ["Tests/**/*.swift"],
            dependencies: [
                .target(name: "FlickrSearch")
            ]
        )
    ]
)
