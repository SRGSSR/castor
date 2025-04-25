//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast

/// An observable object tracking playback progress.
public final class ProgressTracker: ObservableObject {
    @Published var player: CastPlayer?
    @Published private var timeProperties: TimeProperties = .empty

    /// Creates a progress tracker updating its progress at the specified interval.
    /// 
    /// - Parameter interval: The interval at which progress must be updated, according to progress of the current
    ///
    /// Additional updates will happen when time jumps or when playback starts or stops.
    public init(interval: CMTime) {
        $player.map { player -> AnyPublisher<TimeProperties, Never> in
            guard let player else { return Just(.empty).eraseToAnyPublisher() }
            return Timer.publish(every: interval.seconds, on: .main, in: .common)
                .autoconnect()
                .map { _ in
                    TimeProperties(time: player.time(), timeRange: player.seekableTimeRange())
                }
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .assign(to: &$timeProperties)
    }
}
