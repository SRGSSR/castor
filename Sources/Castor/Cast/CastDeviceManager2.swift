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

    init<V, M>(
        volumeRecipe: V,
        mutedRecipe: M
    ) where V: MutableReceiverStateRecipe2, M: MutableReceiverStateRecipe2, V.Value == Float, M.Value == Bool, V.Service == GCKSessionManager, M.Service == GCKSessionManager {
        __volume.synchronize(using: V.self, service: service)
        __isMuted.synchronize(using: M.self, service: service)
    }
}
