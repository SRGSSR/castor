//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct PlayerView: View {
    @State private var player = AVPlayer()
    let media: Media

    var body: some View {
        switch media.type {
        case let .url(url):
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .onAppear {
                    player.replaceCurrentItem(with: .init(url: url))
                    player.play()
                }
        case .urn:
            ContentUnavailableView("Not playable locally", systemImage: "play.slash.fill")
        }
    }
}
