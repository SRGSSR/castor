//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast

class DemoAppViewModel {
    let cast: Cast

    init() {
        Self.configureGoogleCast()
        UserDefaults.registerDefaults()
        cast = Cast(configuration: .standard)
        cast.delegate = self
    }

    private static func configureGoogleCast() {
        let criteria = GCKDiscoveryCriteria(applicationID: UserDefaults.standard.receiver.identifier)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        options.launchOptions?.androidReceiverCompatible = true
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
    }
}

extension DemoAppViewModel: CastDelegate {
    func cast(_ cast: Cast, didStartSessionWithPlayer player: CastPlayer) {
        print("--> didStartSessionWithPlayer")
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer) {
        print("--> willStopSessionWithPlayer")
    }
}
