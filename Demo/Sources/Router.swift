//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import Foundation
import SwiftUI

final class Router: ObservableObject {
    @Published var presented: Destination?
}

extension Router {
    enum Destination: Identifiable, Hashable {
        case player(content: PlayerContent?)
        case expandedCastPlayer(cast: Cast)

        var id: String {
            switch self {
            case .player:
                "player"
            case .expandedCastPlayer:
                "expandedCastPlayer"
            }
        }

        @MainActor
        @ViewBuilder
        func view() -> some View {
            switch self {
            case let .player(content: content):
                PlayerView(content: content)
            case let .expandedCastPlayer(cast: cast):
                ExpandedCastPlayerView(cast: cast)
            }
        }
    }
}

extension Router: CastDelegate {
    func castStartSession() {
        if case .player = presented {
            presented = nil
        }
    }

    func castEndSession(with state: CastResumeState?) {
        if case .expandedCastPlayer = presented {
            presented = nil
        }
    }
}
