import ProjectDescription
import ProjectDescriptionHelpers
import FlikrPhotoPlugin

let project = Project.sharedLibrary(
    from: .init(
        name: "FlickrService",
        dependencies: [
            .project(target: "HttpClient", path: .relativeToRoot("Targets/HttpClient"))
        ]
    )
)
