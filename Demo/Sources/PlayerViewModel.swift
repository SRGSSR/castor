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

struct StartInfo {
    let index: Int
    let time: CMTime
}

final class PlayerViewModel {
    let player = Player()

    private var timeRange: CMTimeRange = .invalid
    private var cancellables = Set<AnyCancellable>()

    private var startInfo: StartInfo?

    var medias: [Media] = [] {
        didSet {
            player.items = medias.map { media in
                if let time = startInfo?.time {
                    media.playerItem(with: .init(position: at(time)))
                }
                else {
                    media.playerItem()
                }
            }
            if let startInfo {
                player.currentItem = player.items[safeIndex: startInfo.index]
            }
            startInfo = nil
        }
    }

    init() {
        player.propertiesPublisher
            .slice(at: \.seekableTimeRange)
            .weakAssign(to: \.timeRange, on: self)
            .store(in: &cancellables)
    }

    func play() {
        player.becomeActive()
        player.play()
    }
}

extension PlayerViewModel {
    func prependItems(from medias: [Media]) {
    }
    func insertItemsBeforeCurrent(from medias: [Media]) {
    }
    func insertItemsAfterCurrent(from medias: [Media]) {
    }
    func appendItems(from medias: [Media]) {
    }
}

extension PlayerViewModel: Castable {
    func castStartSession() -> CastResumeState? {
        let resumeState = CastResumeState(assets: castAssets(), index: currentIndex(), time: time())
        medias = []
        return resumeState
    }

    func castEndSession(with state: CastResumeState?) {
        if let state {
            let startTime = state.time.isValid ? state.time : .zero
            startInfo = .init(index: state.index, time: startTime)
            medias = state.assets.map { Media(from: $0) }
            play()
        }
        else {
            medias = []
        }
    }

    private func castAssets() -> [CastAsset] {
        medias.map { media in
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
