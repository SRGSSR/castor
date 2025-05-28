//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKSessionManager: ReceiverService {
    var requester: GCKCastSession? {
        guard let currentCastSession else { return nil }
        return currentCastSession.canAdjustVolume ? currentCastSession : nil
    }

    func status(from requester: GCKCastSession) -> DeviceSettings? {
        .init(volume: requester.currentDeviceVolume, isMuted: requester.currentDeviceMuted)
    }
}
