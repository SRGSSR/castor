//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia

extension CastPlayer {
    private func pulsePublisher(interval: CMTime) -> AnyPublisher<Void, Never> {
        Timer.publish(every: interval.seconds, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .eraseToAnyPublisher()
    }

    private func smoothTimePublisher(interval: CMTime) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest3(
            $_targetSeekTime,
            objectWillChange,
            pulsePublisher(interval: interval)
        )
        .weakCapture(self)
        .map { ($0.0, $1) }
        .map { targetSeekTime, player in
            targetSeekTime ?? player.time()
        }
        .eraseToAnyPublisher()
    }

    func timePropertiesPublisher(interval: CMTime) -> AnyPublisher<TimeProperties, Never> {
        smoothTimePublisher(interval: interval)
            .weakCapture(self)
            .map { time, player in
                TimeProperties(time: time, timeRange: player.seekableTimeRange())
            }
            .eraseToAnyPublisher()
    }
}
