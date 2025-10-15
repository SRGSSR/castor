//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

@MainActor
public final class CastDeviceManager2: ObservableObject {
    @MutableReceiverState2(VolumeRecipe2.self)
    private var _volume

    @MutableReceiverState2(MutedRecipe2.self)
    private var _isMuted
}
