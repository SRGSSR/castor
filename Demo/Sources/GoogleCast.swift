//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

enum GoogleCast {
    static var isActive: Bool {
        GCKCastContext.sharedInstance().sessionManager.currentCastSession != nil
    }

    static func load(url: URL) {
        let mediaInfoBuilder = GCKMediaInformationBuilder()
        mediaInfoBuilder.contentURL = url
        let mediaInformation = mediaInfoBuilder.build()
        _ = GCKCastContext
            .sharedInstance().sessionManager.currentSession?.remoteMediaClient?
            .loadMedia(mediaInformation)
    }
}
