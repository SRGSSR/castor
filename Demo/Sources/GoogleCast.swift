//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

class GoogleCast: NSObject, ObservableObject {
    var isActive: Bool {
        remoteMediaClient != nil
    }

    var isLoaded: Bool {
        remoteMediaClient != nil && mediaStatus != nil
    }

    @Published private(set) var mediaStatus: GCKMediaStatus?
    @Published private var remoteMediaClient: GCKRemoteMediaClient? {
        didSet {
            oldValue?.remove(self)
            remoteMediaClient?.add(self)
        }
    }

    override init() {
        let context = GCKCastContext.sharedInstance()
        super.init()
        context.sessionManager.add(self)
        remoteMediaClient = context.sessionManager.currentCastSession?.remoteMediaClient
        mediaStatus = remoteMediaClient?.mediaStatus
    }

    private static func mediaInformation(from stream: Stream) -> GCKMediaInformation {
        let mediaInfoBuilder = GCKMediaInformationBuilder()
        mediaInfoBuilder.contentURL = stream.url

        let metadata = GCKMediaMetadata()
        metadata.setString(stream.title, forKey: kGCKMetadataKeyTitle)
        metadata.removeAllMediaImages()
        metadata.addImage(.init(url: stream.imageUrl, width: 0, height: 0))

        mediaInfoBuilder.metadata = metadata
        return mediaInfoBuilder.build()
    }

    private static func queueItem(from stream: Stream) -> GCKMediaQueueItem {
        let queueItemBuilder = GCKMediaQueueItemBuilder()
        queueItemBuilder.mediaInformation = mediaInformation(from: stream)
        queueItemBuilder.autoplay = true
        return queueItemBuilder.build()
    }

    static func load(streams: [Stream]) {
        _ = GCKCastContext
            .sharedInstance().sessionManager.currentSession?.remoteMediaClient?
            .queueLoad(streams.map(queueItem(from:)), with: .init())
    }

    static func load(stream: Stream) {
        Self.load(streams: [stream])
    }
}

extension GoogleCast: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        remoteMediaClient = session.remoteMediaClient
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        remoteMediaClient = session.remoteMediaClient
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didSuspend session: GCKCastSession,
        with reason: GCKConnectionSuspendReason
    ) {
        // TODO: Should we reset our remoteMediaClient?
        remoteMediaClient = nil
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didEnd session: GCKCastSession,
        withError error: (any Error)?
    ) {
        remoteMediaClient = nil
    }
}

extension GoogleCast: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}
