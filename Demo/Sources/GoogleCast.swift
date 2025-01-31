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

    static func load(stream: Stream) {
        let mediaInfoBuilder = GCKMediaInformationBuilder()
        mediaInfoBuilder.contentURL = stream.url

        let metadata = GCKMediaMetadata()
        metadata.setString(stream.title, forKey: kGCKMetadataKeyTitle)
        metadata.removeAllMediaImages()
        metadata.addImage(.init(url: stream.imageUrl, width: 0, height: 0))

        mediaInfoBuilder.metadata = metadata
        let mediaInformation = mediaInfoBuilder.build()

        _ = GCKCastContext
            .sharedInstance().sessionManager.currentSession?.remoteMediaClient?
            .loadMedia(mediaInformation)
    }
}
