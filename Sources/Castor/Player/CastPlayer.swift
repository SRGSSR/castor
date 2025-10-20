//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import GoogleCast

/// A player used to interact with a Cast receiver device.
///
/// You do not instantiate a `CastPlayer` directly. Instead, use a ``Cast`` instance to manage receivers and establish
/// sessions. Then use the ``Cast/player`` it provides to control playback, receive status updates, access metadata,
/// and manage items for the current session.
@MainActor
public final class CastPlayer: NSObject, ObservableObject {
    let remoteMediaClient: GCKRemoteMediaClient

    @ReceiverState2 var _mediaStatus: GCKMediaStatus?

    @MutableReceiverState private var _repeatMode: CastRepeatMode
    @MutableReceiverState private var _currentItemId: GCKMediaQueueItemID
    @MutableReceiverState var _shouldPlay: Bool
    @MutableReceiverState var _playbackSpeed: Float
    @MutableReceiverState var _activeTracks: [CastMediaTrack]
    @MutableReceiverState var _targetSeekTime: CMTime?
    @MutableReceiverState var _items: [CastPlayerItem]

    /// The current item.
    ///
    /// Setting this property to `nil` or to an item that does not belong to the list has no effect.
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

    /// The mode that determines how the player repeats playback of items in its queue.
    ///
    /// > Note: Use ``CastLoadOptions`` to configure behavior when loading items.
    public var repeatMode: CastRepeatMode {
        get {
            _repeatMode
        }
        set {
            _repeatMode = newValue
        }
    }

    var configuration: CastConfiguration

    var mediaSelectionPreferredLanguages: [AVMediaCharacteristic: [String]] = [:] {
        didSet {
            applyMediaSelectionPreferredLanguages(with: _mediaStatus)
        }
    }

    private var startedSessionID: Int?
    private var shouldApplyMediaSelection = true

    init?(remoteMediaClient: GCKRemoteMediaClient?, configuration: CastConfiguration) {
        guard let remoteMediaClient else { return nil }

        self.remoteMediaClient = remoteMediaClient
        self.configuration = configuration

        __repeatMode = .init(service: remoteMediaClient, recipe: RepeatModeRecipe.self)
        __currentItemId = .init(service: remoteMediaClient, recipe: CurrentItemIdRecipe.self)
        __mediaStatus = .init(service: remoteMediaClient, recipe: MediaStatusRecipe.self)
        __shouldPlay = .init(service: remoteMediaClient, recipe: ShouldPlayRecipe.self)
        __playbackSpeed = .init(service: remoteMediaClient, recipe: PlaybackSpeedRecipe.self)
        __activeTracks = .init(service: remoteMediaClient, recipe: ActiveTracksRecipe.self)
        __targetSeekTime = .init(service: remoteMediaClient, recipe: TargetSeekTimeRecipe.self)
        __items = .init(service: remoteMediaClient, recipe: ItemsRecipe.self)

        super.init()

        remoteMediaClient.add(self)
    }
}

extension CastPlayer: @preconcurrency GCKRemoteMediaClientListener {
    // swiftlint:disable:next missing_docs
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didStartMediaSessionWithID sessionID: Int) {
        startedSessionID = sessionID
    }

    // swiftlint:disable:next missing_docs
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if startedSessionID != nil && shouldApplyMediaSelection {
            shouldApplyMediaSelection = !applyMediaSelectionPreferredLanguages(with: mediaStatus)
        }
    }
}
