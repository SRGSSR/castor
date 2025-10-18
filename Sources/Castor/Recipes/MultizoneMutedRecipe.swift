//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MultizoneMutedRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = false

    private let service: MultizoneDeviceService

    var update: ((Bool) -> Void)?
    var completion: ((Bool) -> Void)?

    init(service: MultizoneDeviceService) {
        self.service = service
        super.init()
        service.add(self)
    }

    static func status(from service: MultizoneDeviceService) -> Bool {
        service.isMuted
    }

    func requestUpdate(to value: Bool) -> Bool {
        let request = service.setMuted(value)
        request.delegate = self
        return true
    }
}

extension MultizoneMutedRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didUpdate device: GCKMultizoneDevice) {
        update?(device.muted)
    }
}

extension MultizoneMutedRecipe: @preconcurrency GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion?(true)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        completion?(false)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        completion?(false)
    }
}
