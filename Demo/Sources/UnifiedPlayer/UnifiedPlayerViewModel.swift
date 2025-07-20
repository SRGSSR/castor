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
    @Published var localMedias: [LocalMedia] = [] {
        didSet {
            localPlayer.items = localMedias.map(\.item)
        }
    }

    @Published var currentLocalMedia: LocalMedia? {
        didSet {
            localPlayer.currentItem = currentLocalMedia?.item
        }
    }

    let localPlayer = Player()
    private(set) var remotePlayer: CastPlayer?

    init(medias: [LocalMedia]) {
        self.localMedias = medias
        currentLocalMedia = medias.first { $0.item == localPlayer.currentItem }
        Publishers.CombineLatest(localPlayer.$currentItem, $localMedias)
            .filter { $0.0 != nil }
            .map { item, medias in
                medias.first { $0.item == item }
            }
            .assign(to: &$currentLocalMedia)
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
                localMedias = content.medias.map(LocalMedia.init)
                currentLocalMedia = localMedias.first { localMedia in
                    localMedia.media == content.medias[state.index]
                }
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
            assets: localMedias.map { $0.media.asset() },
            index: currentLocalMedia.flatMap { localMedias.firstIndex(of: $0) } ?? 0,
            time: localPlayer.time()
        )
    }
}
