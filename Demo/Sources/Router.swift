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
    func castStartSession() {
        destination = nil
    }

    func castEndSession(with state: CastResumeState) {
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

    func castAsset(from information: CastMediaInformation) -> CastAsset? {
        if let identifier = information.identifier, identifier.hasPrefix("urn:") {
            return .custom(identifier: identifier, metadata: information.metadata)
        }
        else if let url = information.url {
            return .simple(url: url, metadata: information.metadata)
        }
        else {
            return nil
        }
    }
}
