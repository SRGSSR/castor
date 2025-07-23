//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast asset representing content to be played.
public struct CastAsset {
    private let resource: CastMediaInformation
    private let customData: Any?
    private let configuration: CastPlaybackConfiguration

    public init(resource: CastMediaInformation, customData: Any? = nil, configuration: CastPlaybackConfiguration = .init()) {
        self.resource = resource
        self.customData = customData
        self.configuration = configuration
    }

    func rawItem() -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = resource.rawMediaInformation
        builder.autoplay = configuration.autoplay
        builder.customData = customData
        return builder.build()
    }
}
