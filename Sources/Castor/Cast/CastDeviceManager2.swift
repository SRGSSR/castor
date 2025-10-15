//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

@MainActor
public final class CastDeviceManager2: ObservableObject {
    @MutableReceiverState2
    private var _volume: Float = 0

    @MutableReceiverState2
    private var _isMuted = false

    private let service = GCKCastContext.sharedInstance().sessionManager

    init() {
        __volume.synchronize(using: VolumeRecipe2.self, service: service)
        __isMuted.synchronize(using: MutedRecipe2.self, service: service)
    }
}
