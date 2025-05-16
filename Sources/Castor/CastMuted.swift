//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastMuted: NSObject {
    private let session: GCKCastSession
    weak var delegate: ChangeDelegate?

    var value: Bool {
        didSet {
            guard session.currentDeviceMuted != value else { return }
            session.setDeviceMuted(value)
        }
    }

    init(sessionManager: GCKSessionManager, session: GCKCastSession) {
        self.session = session
        self.value = session.currentDeviceMuted
        super.init()
        sessionManager.add(self)
    }
}

extension CastMuted: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        value = muted
        delegate?.didChange()
    }
}
