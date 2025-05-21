//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedSynchronizer: NSObject {
    private let session: GCKCastSession

    var isMuted: Bool {
        didSet {
            guard session.currentDeviceMuted != isMuted else { return }
            session.setDeviceMuted(isMuted)
        }
    }

    init(sessionManager: GCKSessionManager, session: GCKCastSession) {
        self.session = session
        self.isMuted = session.currentDeviceMuted
        super.init()
        sessionManager.add(self)
    }
}

extension MutedSynchronizer: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        isMuted = muted
    }
}
