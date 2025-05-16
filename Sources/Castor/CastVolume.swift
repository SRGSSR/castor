//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol ChangeDelegate: AnyObject {
    func didChange()
}

final class CastVolume: NSObject {
    private let session: GCKCastSession
    weak var delegate: ChangeDelegate?

    private weak var request: GCKRequest?
    private var requestValue: Float?
    private var pendingRequestValue: Float?

    var value: Float {
        didSet {
            guard session.currentDeviceVolume != value else { return }
            if request == nil {
                request = request(to: value)
            }
            pendingRequestValue = value
        }
    }

    let range: ClosedRange<Float> = 0...1

    init?(sessionManager: GCKSessionManager, session: GCKCastSession?) {
        guard let session, session.device.hasCapabilities(.masterOrFixedVolume) else { return nil }
        self.session = session
        self.value = session.currentDeviceVolume
        super.init()
        sessionManager.add(self)
    }

    convenience init?(sessionManager: GCKSessionManager) {
        self.init(sessionManager: sessionManager, session: sessionManager.currentCastSession)
    }

    private func request(to value: Float) -> GCKRequest {
        let request = session.setDeviceVolume(value)
        request.delegate = self
        requestValue = value
        return request
    }
}

extension CastVolume: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        if let pendingRequestValue {
            guard abs(volume - pendingRequestValue) < 0.01 else { return }
            delegate?.didChange()
            self.pendingRequestValue = nil
        }
        else {
            self.value = volume
            delegate?.didChange()
        }
    }
}

extension CastVolume: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestValue, pendingRequestValue != requestValue else { return }
        self.request = self.request(to: pendingRequestValue)
    }
}
