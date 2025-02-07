//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast
import SwiftUI

struct CastPlayerView: View {
    @StateObject private var player = CastPlayer()

    var body: some View {
        if let title {
            Text(title)
        }
    }

    private var title: String? {
        player.mediaInformation?.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }
}
