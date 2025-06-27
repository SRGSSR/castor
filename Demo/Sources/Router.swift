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
    func cast(_ cast: Cast, startSessionWithState state: CastResumeState?) {
        destination = nil
    }

    func cast(_ cast: Cast, endSessionWithState state: CastResumeState?) {
        guard let state else { return }
        let medias = state.assets.suffix(from: state.index).enumerated().compactMap { index, asset in
            if index == 0 {
                return Media.media(from: asset, startTime: state.time)
            }
            else {
                return Media.media(from: asset)
            }
        }
        destination = .player(medias)
    }
}
