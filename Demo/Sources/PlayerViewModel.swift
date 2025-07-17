//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import Combine
import PillarboxCoreBusiness
import PillarboxPlayer
import SwiftUI

final class PlayerViewModel {
    let player = Player()

    private var timeRange: CMTimeRange = .invalid
    private var cancellables = Set<AnyCancellable>()

    var content: PlayerContent? {
        didSet {
            if let content {
                player.items = content.items()
                player.currentItem = player.items[safeIndex: content.startIndex]
            }
            else {
                player.removeAllItems()
            }
        }
    }

    init() {
        player.propertiesPublisher
            .slice(at: \.seekableTimeRange)
            .weakAssign(to: \.timeRange, on: self)
            .store(in: &cancellables)
    }

    func play() {
        player.play()
    }
}

extension PlayerViewModel: Castable {
    func castResumeState() -> CastResumeState? {
        .init(assets: castAssets(), index: currentIndex(), time: time())
    }

    private func castAssets() -> [CastAsset] {
        guard let content else { return [] }
        return content.medias.map { media in
            switch media.type {
            case let .url(url):
                return .simple(url: url, metadata: media.castMetadata())
            case let .urn(urn):
                return .custom(identifier: urn, metadata: media.castMetadata())
            }
        }
    }

    private func currentIndex() -> Int? {
        guard let currentItem = player.currentItem else { return nil }
        return player.items.firstIndex(of: currentItem)
    }

    private func time() -> CMTime {
        guard timeRange.isValid && !timeRange.isEmpty else { return .invalid }
        return player.time() - timeRange.start
    }
}
