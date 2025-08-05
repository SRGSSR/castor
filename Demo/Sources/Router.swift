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
        case localPlayer(media: Media)
        case remotePlayer
        case unifiedPlayer(media: Media)

        var id: String {
            switch self {
            case .localPlayer:
                "localPlayer"
            case .remotePlayer:
                "remotePlayer"
            case .unifiedPlayer:
                "unifiedPlayer"
            }
        }

        @MainActor
        @ViewBuilder
        func view() -> some View {
            switch self {
            case let .localPlayer(media: media):
                LocalPlayerView(media: media)
            case .remotePlayer:
                RemotePlayerView()
            case let .unifiedPlayer(media: media):
                UnifiedPlayerView(media: media)
            }
        }
    }
}

extension Router: CastDelegate {
    func castStartSession() {
        switch presented {
        case .localPlayer:
            presented = nil
        default:
            break
        }
    }

    func castEndSession(with state: CastResumeState?) {
        switch presented {
        case .remotePlayer:
            presented = nil
        default:
            break
        }
    }
}
