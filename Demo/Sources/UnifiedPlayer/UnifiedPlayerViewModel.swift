//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Combine
import Foundation
import PillarboxPlayer

class UnifiedPlayerViewModel: ObservableObject {
    @Published var medias: [Media] {
        didSet {
            localPlayer.items = playerContent.items()
        }
    }

    @Published var currentMedia: Media? {
        didSet {
            if let index = medias.firstIndex(where: { $0 == currentMedia }) {
                localPlayer.currentItem = localPlayer.items[safeIndex: index]
            }
        }
    }

    let localPlayer = Player()
    private(set) var remotePlayer: CastPlayer?

    private(set) var playerContent: PlayerContent {
        didSet {
            medias = playerContent.medias
            currentMedia = playerContent.medias[playerContent.startIndex]
        }
    }

    init(playerContent: PlayerContent) {
        self.playerContent = playerContent
        medias = playerContent.medias
        currentMedia = playerContent.medias[playerContent.startIndex]
    }

    func bind(remotePlayer: CastPlayer?) {
        self.remotePlayer = remotePlayer
    }
}

extension UnifiedPlayerViewModel: CastDelegate {
    func castStartSession() {}

    func castEndSession(with state: CastResumeState?) {
        if let state {
            let medias = state.assets.compactMap(Media.init)
            let time = state.time.isValid ? state.time : .zero
            if let content = PlayerContent(medias: medias, startIndex: state.index, startTime: time) {
                playerContent = content
            }
        }
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

extension UnifiedPlayerViewModel: Castable {
    func castResumeState() -> CastResumeState? {
        .init(
            assets: medias.map { $0.asset() },
            index: currentMedia.flatMap { medias.firstIndex(of: $0) } ?? 0,
            time: localPlayer.time()
        )
    }
}
