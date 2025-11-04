//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit

enum ProjectLink {
    case apple
    case documentation
    case pillarbox
    case project
    case swiftPackageIndex
    case website

    var url: URL {
        switch self {
        case .apple:
            Self.gitHubBaseUrl().appending(path: "srgssr/castor")
        case .documentation:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-documentation")
        case .pillarbox:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-apple")
        case .project:
            Self.gitHubBaseUrl().appending(path: "orgs/SRGSSR/projects/9")
        case .swiftPackageIndex:
            URL(string: "https://swiftpackageindex.com/SRGSSR/castor")!
        case .website:
            URL(string: "https://www.pillarbox.ch")!
        }
    }

    private static func gitHubBaseUrl() -> URL {
        var url = URL("github://github.com")
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }
}

extension UIApplication {
    func open(_ link: ProjectLink) {
        open(link.url)
    }
}
