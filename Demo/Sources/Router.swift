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
        case player([Media])

        var id: String {
            switch self {
            case .player:
                "player"
            }
        }

        func view() -> some View {
            switch self {
            case let .player(medias):
                PlayerView(medias: medias)
            }
        }
    }
}

extension Router: CastDelegate {
    func cast(_ cast: Cast, didStartSessionWithPlayer player: CastPlayer) {
        destination = nil
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer, currentAsset: CastAsset?, assets: [CastAsset]) {
        print("--> 🔴 StopSessionWithPlayer (assets: \(assets.count))")
        let medias = assets.compactMap { Media.media(from: $0) }
        destination = .player(medias)
        cast.endSession()
    }
}
