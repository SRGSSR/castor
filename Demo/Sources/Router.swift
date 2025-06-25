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
    let cast: Cast

    @Published var destination: Destination?
    private var previousDestination: Destination?

    var dataSource: CastDataSource? {
        didSet {
            print("--> dataSource \(dataSource)")
        }
    }

    init(cast: Cast) {
        self.cast = cast
        cast.delegate = self
    }
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
        print("--> from player to cast player - \(dataSource)")
        if let url = (dataSource?.player.currentItem?.asset as? AVURLAsset)?.url {
            player.loadItem(from: .simple(url: url, metadata: .init(title: "Item from native player")))
        }
        previousDestination = destination
        destination = nil
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer) {
        print("--> from cast player to player - \(dataSource)")
        destination = previousDestination
        previousDestination = nil
    }
}
