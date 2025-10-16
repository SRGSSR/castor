//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MultizoneDevicesRecipe: NSObject, ReceiverStateRecipe {
    static var defaultValue: [CastMultizoneDevice] = []

    var update: (([CastMultizoneDevice]) -> Void)?

    private var devices: [CastMultizoneDevice] = [] {
        didSet {
            update?(devices)
        }
    }

    init(service: GCKCastSession?) {
        super.init()
        service?.add(self)
    }

    static func status(from service: GCKCastSession?) -> [CastMultizoneDevice] {
        []
    }
}

extension MultizoneDevicesRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didReceive multizoneStatus: GCKMultizoneStatus) {
        devices = multizoneStatus.devices.map { $0.toCastDevice() }
    }
}
