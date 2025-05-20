//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast

final class TimeManager: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    @Published private var mediaStatus: GCKMediaStatus?
    @Published private(set) var targetTime: CMTime?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.add(self)
    }

    func request(for time: CMTime) {
        targetTime = time
        let options = GCKMediaSeekOptions()
        options.interval = time.seconds
        let request = remoteMediaClient.seek(with: options)
        request.delegate = self
    }

    func time() -> CMTime {
        remoteMediaClient.time()
    }

    func seekableTimeRange() -> CMTimeRange {
        remoteMediaClient.seekableTimeRange()
    }
}

extension TimeManager: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}

extension TimeManager {
    private func pulsePublisher(interval: CMTime) -> AnyPublisher<Void, Never> {
        Timer.publish(every: interval.seconds, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .eraseToAnyPublisher()
    }

    private func smoothTimePublisher(interval: CMTime) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest3(
            $targetTime,
            $mediaStatus,
            pulsePublisher(interval: interval)
        )
        .map { [remoteMediaClient] targetSeekTime, _, _ in
            targetSeekTime ?? remoteMediaClient.time()
        }
        .eraseToAnyPublisher()
    }

    func timePropertiesPublisher(interval: CMTime) -> AnyPublisher<TimeProperties, Never> {
        smoothTimePublisher(interval: interval)
            .map { [remoteMediaClient] time in
                TimeProperties(time: time, timeRange: remoteMediaClient.seekableTimeRange())
            }
            .eraseToAnyPublisher()
    }
}

extension TimeManager: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetTime = nil
    }
}
