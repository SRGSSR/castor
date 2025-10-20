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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(completeRequest), object: nil)
        perform(#selector(completeRequest), with: nil, afterDelay: 0.1)
        _ = service.setMuted(value)
        return true
    }

    @objc
    private func completeRequest() {
        completion?(true)
    }
}

extension MultizoneMutedRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didUpdate device: GCKMultizoneDevice) {
        guard device == service.device.rawDevice else { return }
        update?(device.muted)
    }
}
