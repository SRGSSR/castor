//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import GoogleCast

public enum Asset {
    case url(URL)
    case id(String)

    func mediaInformationBuilder() -> GCKMediaInformationBuilder {
        switch self {
        case let .url(url):
            return GCKMediaInformationBuilder(contentURL: url)
        case let .id(id):
            let builder = GCKMediaInformationBuilder()
            builder.contentID = id
            return builder
        }
    }
}
