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
        let resumeState = CastResumeState(assets: castAssets(), index: currentIndex(), time: time())
        entries = []
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
            case let .url(url):
                return .simple(url: url, metadata: media.castMetadata())
            case let .urn(urn):
                return .custom(identifier: urn, metadata: media.castMetadata())
            }
        }
    }

    private func resume(from state: CastResumeState?) {
        guard let state, let entry = entries[safeIndex: state.index] else { return }
        let startTime = state.time.isValid ? state.time : .zero
        player.resume(at(startTime), in: entry.item)
        play()
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
