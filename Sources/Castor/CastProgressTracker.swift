//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast

/// An observable object tracking playback progress.
public final class CastProgressTracker: ObservableObject {
    @Published private var _progress: Float?

    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: CastPlayer?

    /// A Boolean describing whether user interaction is currently changing the progress value.
    @Published public var isInteracting = false {
        willSet {
            if !newValue, let progress = _progress {
                seek(to: progress)
            }
        }
    }

    /// The current progress.
    ///
    /// Returns a value in `range`. The progress might be different from the actual player progress during
    /// user interaction.
    ///
    /// This property returns 0 when no progress information is available. Use `isProgressAvailable` to check whether
    /// progress is available or not.
    public var progress: Float {
        get {
            Self.validProgress(_progress, in: range)
        }
        set {
            guard _progress != nil else { return }
            _progress = Self.validProgress(newValue, in: range)
        }
    }

    /// A Boolean reporting whether progress information is available.
    ///
    /// This Boolean is a recommendation you can use to entirely hide progress information in cases where it is not
    /// meaningful (e.g., when loading content or for livestreams).
    public var isProgressAvailable: Bool {
        _progress != nil
    }

    /// The current time range.
    ///
    /// Returns `.invalid` when the time range is unknown.
    public var timeRange: CMTimeRange {
        player?.seekableTimeRange() ?? .invalid
    }

    /// The time corresponding to the current progress.
    ///
    /// Returns `.invalid` when the time range is unknown. The returned value might be different from the player current
    /// time when interaction takes place.
    public var time: CMTime {
        Self.time(forProgress: _progress, in: timeRange)
    }

    /// The allowed range for progress values.
    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

    /// Creates a progress tracker updating its progress at the specified interval.
    ///
    /// - Parameter interval: The interval at which progress must be updated, according to progress of the current
    ///
    /// Additional updates will happen when time jumps or when playback starts or stops.
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
