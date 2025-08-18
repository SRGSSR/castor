//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import GoogleCast

/// A cast player.
@MainActor
public final class CastPlayer: NSObject, ObservableObject {
    let remoteMediaClient: GCKRemoteMediaClient

    @MutableReceiverState(RepeatModeRecipe.self)
    private var _repeatMode

    @MutableReceiverState(CurrentItemIdRecipe.self)
    private var _currentItemId

    @ReceiverState(MediaStatusRecipe.self)
    var _mediaStatus

    @MutableReceiverState(ShouldPlayRecipe.self)
    var _shouldPlay

    @MutableReceiverState(PlaybackSpeedRecipe.self)
    var _playbackSpeed

    @MutableReceiverState(ActiveTracksRecipe.self)
    var _activeTracks

    @MutableReceiverState(TargetSeekTimeRecipe.self)
    var _targetSeekTime

    @MutableReceiverState(ItemsRecipe.self)
    var _items

    /// The current item.
    ///
    /// Does nothing if set to `nil` or to an item that does not belong to the list.
    ///
    /// > Important: Use ``CastPlayer/currentAsset`` to access metadata for the current item.
    public var currentItem: CastPlayerItem? {
        get {
            items.first { $0.id == _currentItemId }
        }
        set {
            guard let newValue, items.contains(newValue) else { return }
            _currentItemId = newValue.id
        }
    }

    /// The mode with which the player repeats playback of items in its queue.
    public var repeatMode: CastRepeatMode {
        get {
            _repeatMode
        }
        set {
            _repeatMode = newValue
        }
    }

    var configuration: CastConfiguration
    var mediaSelectionPreferredLanguages: [AVMediaCharacteristic: [String]] = [:]

    var isLoading = false {
        didSet {
            guard isLoading != oldValue else { return }
            applyMediaSelectionPreferredLanguages()
        }
    }

    init?(remoteMediaClient: GCKRemoteMediaClient?, configuration: CastConfiguration) {
        guard let remoteMediaClient else { return nil }

        self.remoteMediaClient = remoteMediaClient
        self.configuration = configuration

        super.init()

        remoteMediaClient.add(self)

        __repeatMode.bind(to: remoteMediaClient)
        __currentItemId.bind(to: remoteMediaClient)
        __mediaStatus.bind(to: remoteMediaClient)
        __shouldPlay.bind(to: remoteMediaClient)
        __playbackSpeed.bind(to: remoteMediaClient)
        __activeTracks.bind(to: remoteMediaClient)
        __targetSeekTime.bind(to: remoteMediaClient)
        __items.bind(to: remoteMediaClient)
    }

    func resume(from state: CastResumeState) {
        loadItems(from: state.assets, with: .init(startTime: state.time, startIndex: state.index))
        state.mediaSelectionCharacteristics.forEach { characteristic in
            guard let language = state.mediaSelectionLanguage(for: characteristic) else { return }
            setMediaSelection(preferredLanguages: [language], for: characteristic)
        }
    }
}

extension CastPlayer: @preconcurrency GCKRemoteMediaClientListener {
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        switch mediaStatus?.playerState {
        case .loading:
            isLoading = true
        case .playing, .paused:
            isLoading = false
        default:
            break
        }
    }
}
