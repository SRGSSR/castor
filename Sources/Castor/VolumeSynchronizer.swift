//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class VolumeSynchronizer: NSObject {
    private let session: GCKCastSession

    private weak var request: GCKRequest?
    private var requestVolume: Float?
    private var pendingRequestVolume: Float?

    var volume: Float {
        didSet {
            guard session.currentDeviceVolume != volume else { return }
            if request == nil {
                request = makeRequest(to: volume)
            }
            pendingRequestVolume = volume
        }
    }

    let range: ClosedRange<Float> = 0...1

    init(sessionManager: GCKSessionManager, session: GCKCastSession) {
        self.session = session
        self.volume = session.currentDeviceVolume
        super.init()
        sessionManager.add(self)
    }

    private func makeRequest(to volume: Float) -> GCKRequest {
        let request = session.setDeviceVolume(volume)
        request.delegate = self
        requestVolume = volume
        return request
    }
}

extension VolumeSynchronizer: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        if let pendingRequestVolume {
            guard abs(volume - pendingRequestVolume) < 0.01 else { return }
            self.pendingRequestVolume = nil
        }
        self.volume = volume
    }
}

extension VolumeSynchronizer: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestVolume, pendingRequestVolume != requestVolume else { return }
        self.request = makeRequest(to: pendingRequestVolume)
    }
}
