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
        print("--> from player to cast player - \(cast.dataSource)")
        if let url = (cast.dataSource?.player.currentItem?.asset as? AVURLAsset)?.url {
            player.loadItem(from: .simple(url: url, metadata: .init(title: "Item from native player")))
        }
        destination = nil
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer) {
        print("--> from cast player to player - \(cast.dataSource)")
//        destination = previousDestination
//        previousDestination = nil
        if let metadata = player.metadata, let title = metadata.title, let imageUrl = metadata.imageUrl(), let url = player.currentItem?.contentUrl {
            cast.endSession()
            destination = .player(Media(title: title, imageUrl: imageUrl, type: .url(url)))
        }
    }
}
