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
        case player(medias: [Media], startIndex: Int, startTime: CMTime)

        var id: String {
            switch self {
            case .player:
                "player"
            }
        }

        @MainActor
        func view() -> some View {
            switch self {
            case let .player(medias: medias, startIndex: startIndex, startTime: startTime):
                PlayerView(medias: medias, startIndex: startIndex, startTime: startTime)
            }
        }
    }
}

extension Router: CastDelegate {
    func castStartSession() {
        destination = nil
    }

    func castEndSession(with state: CastResumeState) {
        let medias = state.assets.compactMap(Media.init(from:))
        destination = .player(medias: medias, startIndex: state.index, startTime: state.time)
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
