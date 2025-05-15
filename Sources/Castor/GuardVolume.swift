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
    private let session: GCKCastSession
    weak var delegate: GuardVolumeDelegate?

    private weak var request: GCKRequest?
    private var requestVolume: Float?
    private var pendingRequestVolume: Float?

    var volume: Float {
        didSet {
            guard session.currentDeviceVolume != volume else { return }
            if request == nil {
                request = volumeRequest(to: volume)
            }
            pendingRequestVolume = volume
        }
    }

    init?(sessionManager: GCKSessionManager, session: GCKCastSession?) {
        guard let session else { return nil }
        self.session = session
        self.volume = session.currentDeviceVolume
        super.init()
        sessionManager.add(self)
    }

    convenience init?(sessionManager: GCKSessionManager) {
        self.init(sessionManager: sessionManager, session: sessionManager.currentCastSession)
    }

    private func volumeRequest(to volume: Float) -> GCKRequest {
        let request = session.setDeviceVolume(volume)
        request.delegate = self
        requestVolume = volume
        return request
    }
}

extension GuardVolume: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        if let pendingRequestVolume {
            if volume == pendingRequestVolume {
                delegate?.didReceiveDeviceVolume()
                self.pendingRequestVolume = nil
            }
        }
        else {
            self.volume = volume
            delegate?.didReceiveDeviceVolume()
        }
    }
}

extension GuardVolume: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestVolume, pendingRequestVolume != requestVolume else { return }
        self.request = volumeRequest(to: pendingRequestVolume)
    }
}
