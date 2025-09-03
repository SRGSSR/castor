//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast

/// An observable object that tracks playback progress.
@MainActor
public final class CastProgressTracker: ObservableObject {
    @Published private var _progress: Float?

    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` when working with SwiftUI.
    @Published public var player: CastPlayer?

    /// A Boolean value indicating whether the user is currently interacting with and changing the progress value.
    @Published public var isInteracting = false {
        willSet {
            if !newValue, let progress = _progress {
                seek(to: progress)
            }
        }
    }

    /// The current progress.
    ///
    /// Returns a value within ``range``. During user interaction, this value may differ from the actual player progress.
    ///
    /// Returns 0 if no progress information is available. Use ``isProgressAvailable`` to check for availability.
    public var progress: Float {
        get {
            Self.validProgress(_progress, in: range)
        }
        set {
            guard _progress != nil else { return }
            _progress = Self.validProgress(newValue, in: range)
        }
    }

    /// A Boolean value indicating whether progress information is available.
    ///
    /// Use this value to hide progress indicators in cases where progress is not meaningful, such as during content
    /// loading or for livestreams.
    public var isProgressAvailable: Bool {
        _progress != nil
    }

    /// The current time range.
    ///
    /// Returns `.invalid` if the time range is unknown.
    public var timeRange: CMTimeRange {
        player?.seekableTimeRange() ?? .invalid
    }

    /// The time corresponding to the current progress.
    ///
    /// Returns `.invalid` if the time range is unknown. During user interaction, this value may differ from the
    /// player's actual current time.
    public var time: CMTime {
        Self.time(forProgress: _progress, in: timeRange)
    }

    /// The valid range for progress values.
    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

    /// Creates a progress tracker that updates at the specified interval.
    ///
    /// - Parameter interval: The interval at which progress should be updated based on the current playback.
    ///
    /// Additional updates occur when the playback time jumps or when playback starts or stops.
    public init(interval: CMTime) {
        $player.map { [$isInteracting] player -> AnyPublisher<Float?, Never> in
            guard let player else { return Just(nil).eraseToAnyPublisher() }
            return Publishers
                .CombineLatest(
                    player.timePropertiesPublisher(interval: interval),
                    $isInteracting
                )
                .filter { !$1 }
                .map { properties, _ in
                    Self.progress(for: properties.time, in: properties.timeRange)
                }
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .assign(to: &$_progress)
    }

    private static func progress(for time: CMTime, in timeRange: CMTimeRange) -> Float? {
        guard time.isValid, timeRange.isValidAndNotEmpty else { return nil }
        return Float((time - timeRange.start).seconds / timeRange.duration.seconds)
    }

    private static func validProgress(_ progress: Float?, in range: ClosedRange<Float>) -> Float {
        (progress ?? 0).clamped(to: range)
    }

    private static func time(forProgress progress: Float?, in timeRange: CMTimeRange) -> CMTime {
        guard let progress else { return .invalid }
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: Float64(progress))
    }

    private func seek(to progress: Float) {
        guard let player else { return }
        let time = Self.time(forProgress: progress, in: timeRange)
        player.seek(to: time)
    }
}
