import ProjectDescription
import ProjectDescriptionHelpers
import FlikrPhotoPlugin


let project = Project.sharedLibrary(
    from: .init(
        name: "ImageCacher",
        dependencies: [
            .project(target: "HttpClient", path: .relativeToRoot("Targets/HttpClient"))
        ]
    )
)
