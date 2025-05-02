//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast

struct MediaSelectionOption {
    private let rawTrack: GCKMediaTrack

    var trackIdentifier: Int {
        rawTrack.identifier
    }

    init(rawTrack: GCKMediaTrack) {
        self.rawTrack = rawTrack
    }
}

final class CastMediaSelection: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    private let mediaCharacteristic: AVMediaCharacteristic

    @Published private(set) var targetOption: MediaSelectionOption?

    init(remoteMediaClient: GCKRemoteMediaClient, mediaCharacteristic: AVMediaCharacteristic) {
        self.remoteMediaClient = remoteMediaClient
        self.mediaCharacteristic = mediaCharacteristic
    }

    func request(for option: MediaSelectionOption) {
        targetOption = option
        // swiftlint:disable:next legacy_objc_type
        let request = remoteMediaClient.setActiveTrackIDs([NSNumber(value: option.trackIdentifier)])
        request.delegate = self
    }
}

extension CastMediaSelection: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetOption = nil
    }
}
