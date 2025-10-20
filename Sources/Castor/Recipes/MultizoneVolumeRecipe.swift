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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(completeRequest), object: nil)
        perform(#selector(completeRequest), with: nil, afterDelay: 0.1)
        _ = service.setVolume(value)
        return true
    }

    @objc
    private func completeRequest() {
        completion?(true)
    }
}

extension MultizoneVolumeRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didUpdate device: GCKMultizoneDevice) {
        guard device == service.device.rawDevice else { return }
        update?(device.volumeLevel)
    }
}
