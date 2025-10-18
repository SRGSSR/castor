//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MultizoneVolumeRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: Float = 0

    private let service: MultizoneDeviceService

    var update: ((Float) -> Void)?
    var completion: ((Bool) -> Void)?

    init(service: MultizoneDeviceService) {
        self.service = service
        super.init()
        service.add(self)
    }

    static func status(from service: MultizoneDeviceService) -> Float {
        service.volume
    }

    func requestUpdate(to value: Float) -> Bool {
        let request = service.setVolume(value)
        request.delegate = self
        return true
    }
}

extension MultizoneVolumeRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didUpdate device: GCKMultizoneDevice) {
        update?(device.volumeLevel)
    }
}

extension MultizoneVolumeRecipe: @preconcurrency GCKRequestDelegate {
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
