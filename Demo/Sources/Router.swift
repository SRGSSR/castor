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
        case player

        var id: String {
            switch self {
            case .player:
                "player"
            }
        }

        @MainActor
        @ViewBuilder
        func view() -> some View {
            switch self {
            case let .player:
                PlayerView()
            }
        }
    }
}

extension Router: CastDelegate {
    func castStartSession() {}

    func castEndSession(with state: CastResumeState?) {}
}
