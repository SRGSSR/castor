//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentSessionRecipe: NSObject, ReceiverStateRecipe {
    static let defaultValue: GCKCastSession? = nil

    private let service: GCKSessionManager

    var update: ((GCKCastSession?) -> Void)?

    init(service: GCKSessionManager) {
        self.service = service
        super.init()
        service.add(self)
    }

    static func status(from service: GCKSessionManager) -> GCKCastSession? {
        service.currentCastSession
    }
}

// TODO: Factor out as a separate object so that the same logic can be applied in all GCKSessionManagerListener-based code
extension CurrentSessionRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        update?(session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        update?(session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKCastSession, with reason: GCKConnectionSuspendReason) {
        update?(nil)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        update?(nil)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        update?(sessionManager.currentCastSession)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: any Error) {
        update?(sessionManager.currentCastSession)
    }
}
