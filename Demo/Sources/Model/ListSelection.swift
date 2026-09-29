//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum ListSelection: Hashable, CaseIterable {
    case playlist
    case chapters

    var name: LocalizedStringResource {
        switch self {
        case .playlist:
            "Playlist"
        case .chapters:
            "Chapters"
        }
    }
}
