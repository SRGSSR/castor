//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation
import SwiftUI

class Router: ObservableObject {
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

    @Published var destination: Destination?
}

extension Router: CastDelegate {
    func cast(_ cast: Cast, didStartSessionWithPlayer player: CastPlayer) {
        print("--> from player to cast player")
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer) {
        print("--> from cast player to player")
    }
}
