//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol GuardVolumeDelegate: AnyObject {
    func didReceiveDeviceVolume()
}

class GuardVolume: NSObject {
    private let sessionManager: GCKSessionManager
    weak var delegate: GuardVolumeDelegate?

    private var canRequestVolume = false

    var volume: Float {
        didSet {
            guard canRequestVolume else { return }
            sessionManager.currentCastSession?.setDeviceVolume(volume)
        }
    }

    private var nonRequestedVolume: Float {
        get {
            volume
        }
        set {
            canRequestVolume = false
            volume = newValue
            canRequestVolume = true
        }
    }

    init(sessionManager: GCKSessionManager) {
        self.sessionManager = sessionManager
        self.volume = sessionManager.currentCastSession?.currentDeviceVolume ?? 0
        super.init()
        sessionManager.add(self)
    }
}

extension GuardVolume: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        nonRequestedVolume = volume
        delegate?.didReceiveDeviceVolume()
    }
}
