import ProjectDescription
import ProjectDescriptionHelpers
import FlikrPhotoPlugin


let project = Project.appModule(
    from: .init(
        name: "GridScreen",
        dependencies: [
            .project(target: "HttpClient", path: .relativeToRoot("Targets/HttpClient")),
            .project(target: "ImageCacher", path: .relativeToRoot("Targets/ImageCacher"))
        ]
    )
)
