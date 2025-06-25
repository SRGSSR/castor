//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import Foundation
import SwiftUI

class Router: ObservableObject {
    @Published var destination: Destination?
}

extension Router {
    enum Destination: Identifiable, Hashable {
        case player(Media)

        var id: String {
            switch self {
            case .player:
                "player"
            }
        }

        func view() -> some View {
            switch self {
            case let .player(media):
                PlayerView(media: media)
            }
        }
    }
}

extension Router: CastDelegate {
    func cast(_ cast: Cast, didStartSessionWithPlayer player: CastPlayer) {
        print("--> 🟢 StartSession (items: \(player.items.count))")
        if let dataSource = cast.dataSource, let url = dataSource.player.url, let metadata = dataSource.metadata {
            player.loadItem(from: .simple(url: url, metadata: metadata))
            destination = nil
        }
    }

    func cast(_ cast: Cast, didUpdate items: [CastPlayerItem], in player: CastPlayer) {
        print("--> 🔵 didUpdate (items: \(items.count))")
        player.items.forEach { $0.fetch() } // If we don't fetch the metadata, we won't be able to start a new local player instance because we won't have the content URL.
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer) {
        print("--> 🔴 StopSession (items: \(player.items.count))")
        if let media = Media.media(from: player.currentItem) {
            destination = .player(media)
            cast.endSession()
        }
    }
}

// TODO: Will be removed
private extension AVPlayer {
    var url: URL? {
        (currentItem?.asset as? AVURLAsset)?.url
    }
}
