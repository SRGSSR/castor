//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastPlayback: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    // swiftlint:disable:next discouraged_optional_boolean
    @Published private(set) var targetShouldPlay: Bool?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func request(shouldPlay: Bool) {
        targetShouldPlay = shouldPlay
        let request = shouldPlay ? remoteMediaClient.play() : remoteMediaClient.pause()
        request.delegate = self
    }
}

extension CastPlayback: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetShouldPlay = nil
    }
}
