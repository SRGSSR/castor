//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast
import SwiftUI

/// A cast player.
public final class CastPlayer: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    /// The player items.
    @Published public private(set) var items: [CastPlayerItem]

    @Published private var mediaStatus: GCKMediaStatus?

    var jumpedItemID: UInt?
    var desiredItemID: UInt?

    private var currentItem: CastPlayerItem? {
        didSet {
            desiredItemID = currentItem?.rawItem.itemID
            print("--> \(desiredItemID)")
            if let id = currentItem?.rawItem.itemID, currentItem != mediaStatus?.currentQueueItem?.toCastPlayerItem() {
                if jumpedItemID == nil {
                    let request = remoteMediaClient.queueJumpToItem(withID: id)
                    jumpedItemID = id
                    request.delegate = self
                }
            }
        }
    }

    init?(remoteMediaClient: GCKRemoteMediaClient?) {
        guard let remoteMediaClient else { return nil }

        self.remoteMediaClient = remoteMediaClient
        mediaStatus = remoteMediaClient.mediaStatus
        items = Self.items(from: remoteMediaClient.mediaQueue)

        super.init()

        remoteMediaClient.add(self)
        remoteMediaClient.mediaQueue.add(self)
    }
}

public extension CastPlayer {
    /// Plays.
    func play() {
        remoteMediaClient.play()
    }

    /// Pauses.
    func pause() {
        remoteMediaClient.pause()
    }

    /// Toggles between play and pause.
    func togglePlayPause() {
        if state == .playing {
            pause()
        }
        else {
            play()
        }
    }

    /// Stops.
    func stop() {
        remoteMediaClient.stop()
    }
}

public extension CastPlayer {
    /// Player state.
    var state: GCKMediaPlayerState {
        mediaStatus?.playerState ?? .unknown
    }

    /// Media information.
    var mediaInformation: GCKMediaInformation? {
        mediaStatus?.mediaInformation
    }

    /// Returns if the player is busy.
    var isBusy: Bool {
        state == .buffering || state == .loading
    }

    /// Current item.
    func item() -> Binding<CastPlayerItem?> {
        .init {
            self.currentItem
        } set: { newValue in
            // TODO: Implement
            self.currentItem = newValue
        }
    }

    /// Time.
    func time() -> CMTime {
        .init(seconds: remoteMediaClient.approximateStreamPosition(), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }

    /// Seekable time range.
    func seekableTimeRange() -> CMTimeRange {
        let start = remoteMediaClient.approximateLiveSeekableRangeStart()
        let end = remoteMediaClient.approximateLiveSeekableRangeEnd()
        if Self.isValidTimeInterval(start), Self.isValidTimeInterval(end), start != end {
            return .init(
                start: .init(seconds: start, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                end: .init(seconds: end, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            )
        }
        else if let streamDuration = mediaInformation?.streamDuration, Self.isValidTimeInterval(streamDuration), streamDuration != 0 {
            return .init(start: .zero, end: .init(seconds: streamDuration, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
        else {
            return .invalid
        }
    }
}

extension CastPlayer: GCKRemoteMediaClientListener {
    // swiftlint:disable:next missing_docs
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}

extension CastPlayer: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        items = Self.items(from: queue)
    }
}

private extension CastPlayer {
    static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }

    static func items(from queue: GCKMediaQueue) -> [CastPlayerItem] {
        var items: [CastPlayerItem] = []
        for index in 0..<queue.itemCount {
            if let item = queue.item(at: index, fetchIfNeeded: true) {
                items.append(item.toCastPlayerItem())
            }
        }
        return items
    }
}

extension CastPlayer: GCKRequestDelegate {
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("--> \(error)")
        jumpedItemID = nil
    }

    public func requestDidComplete(_ request: GCKRequest) {
        if let desiredItemID {
            print("--> complete with DIID: \(desiredItemID)")
            let request = remoteMediaClient.queueJumpToItem(withID: desiredItemID)
            jumpedItemID = desiredItemID
            self.desiredItemID = nil
            request.delegate = self
        }
        else {
            print("--> complete")
            jumpedItemID = nil
        }
    }

    public func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("--> didAbortWith: \(abortReason)")
        jumpedItemID = nil
    }
}
