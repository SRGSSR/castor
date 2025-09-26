//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Combine
import CoreMedia
import PillarboxPlayer
import SwiftUI

final class PlayerViewModel: ObservableObject {
    let player = Player()

    private var timeRange: CMTimeRange = .invalid
    private var cancellables = Set<AnyCancellable>()

    @Published var entries: [PlaylistEntry] = [] {
        didSet {
            player.items = entries.map(\.item)
        }
    }

    @Published var currentEntry: PlaylistEntry? {
        didSet {
            player.currentItem = currentEntry?.item
        }
    }

    init() {
        player.propertiesPublisher
            .slice(at: \.seekableTimeRange)
            .weakAssign(to: \.timeRange, on: self)
            .store(in: &cancellables)

        configureCurrentEntryPublisher()
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    private func configureCurrentEntryPublisher() {
        Publishers.CombineLatest(player.$currentItem, $entries)
            .map { item, entries in
                entries.first { $0.item == item }
            }
            .assign(to: &$currentEntry)
    }
}

extension PlayerViewModel {
    func prependItems(from entries: [PlaylistEntry]) {
        self.entries.insert(contentsOf: entries, at: 0)
    }

    func insertItemsBeforeCurrent(from entries: [PlaylistEntry]) {
        guard let index = currentIndex() else { return }
        self.entries.insert(contentsOf: entries, at: index)
    }

    func insertItemsAfterCurrent(from entries: [PlaylistEntry]) {
        guard let index = currentIndex() else { return }
        self.entries.insert(contentsOf: entries, at: player.items.index(after: index))
    }

    func appendItems(from entries: [PlaylistEntry]) {
        self.entries.append(contentsOf: entries)
    }
}

extension PlayerViewModel: Castable {
    func castStartSession() -> CastResumeState? {
        defer {
            entries = []
        }
        let options = CastLoadOptions(
            startTime: time(),
            startIndex: currentIndex() ?? 0,
            shouldPlay: player.shouldPlay,
            playbackSpeed: player.effectivePlaybackSpeed,
            repeatMode: .off // TODO
        )
        guard var resumeState = CastResumeState(assets: castAssets(), options: options) else {
            return nil
        }
        resumeState.setMediaSelection(from: player)
        return resumeState
    }

    func castEndSession(with state: CastResumeState?) {
        if let state {
            entries = state.assets.map { .init(media: Media(from: $0)) }
            resume(from: state)
        }
        else {
            entries = []
        }
    }

    private func castAssets() -> [CastAsset] {
        entries.map(\.media).map { media in
            switch media.type {
            case let .urn(urn):
                // TODO: The SRG SSR receiver should be able to handle entities in a near future. Replace with `.entity`
                //       when this is the case.
                return .identifier(urn, metadata: media.castMetadata())
            case let .url(url, configuration: configuration):
                return .url(url, configuration: configuration, metadata: media.castMetadata())
            }
        }
    }

    private func resume(from resumeState: CastResumeState?) {
        guard let resumeState else { return }
        let options = resumeState.options
        guard let entry = entries[safeIndex: options.startIndex] else { return }
        let startTime = options.startTime.isValid ? options.startTime : .zero
        player.setMediaSelection(from: resumeState)
        player.setDesiredPlaybackSpeed(options.playbackSpeed)
        player.shouldPlay = options.shouldPlay
        player.resume(at(startTime), in: entry.item)
    }

    private func currentIndex() -> Int? {
        guard let currentEntry else { return nil }
        return entries.firstIndex(of: currentEntry)
    }

    private func time() -> CMTime {
        guard timeRange.isValid && !timeRange.isEmpty else { return .invalid }
        return player.time() - timeRange.start
    }
}
