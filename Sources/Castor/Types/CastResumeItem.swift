//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

struct CastResumeItem {
    let item: GCKMediaQueueItem
    let asset: CastAsset

    init?(from item: GCKMediaQueueItem, with delegate: CastDelegate) {
        guard let resource = CastMediaInformation(rawMediaInformation: item.mediaInformation), let asset = delegate.castAsset(from: resource) else {
            return nil
        }
        self.item = item
        self.asset = asset
    }
}
