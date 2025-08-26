//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast
import SwiftUI

public extension CastPlayer {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        Self.mediaSelectionCharacteristics(from: _mediaStatus)
    }

    /// The list of media options associated with a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic.
    ///
    /// Use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [CastMediaSelectionOption] {
        Self.mediaSelectionOptions(from: _mediaStatus, for: characteristic)
    }

    /// The currently selected media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option.
    ///
    /// You can use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> CastMediaSelectionOption {
        let options = mediaSelectionOptions(for: characteristic)
        let currentOption = currentMediaOption(for: characteristic)
        return options.contains(currentOption) ? currentOption : .off
    }

    /// Selects a media option for a characteristic.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    ///
    /// You can use `mediaSelectionCharacteristics` to retrieve available characteristics. This method does nothing when
    /// attempting to set an option that is not supported.
    func select(mediaOption: CastMediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        var activeTracks = _activeTracks
        activeTracks.removeAll { $0.mediaCharacteristic == characteristic }
        switch mediaOption {
        case .off:
            break
        case let .on(track):
            activeTracks.append(track)
        }
        _activeTracks = activeTracks
    }

    /// A binding to read and write the current media selection for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The binding.
    func mediaOption(for characteristic: AVMediaCharacteristic) -> Binding<CastMediaSelectionOption> {
        .init {
            self.selectedMediaOption(for: characteristic)
        } set: { newValue in
            self.select(mediaOption: newValue, for: characteristic)
        }
    }

    /// The current media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The current option.
    ///
    /// Unlike `selectedMediaOption(for:)` this method provides the currently applied option. This method can
    /// be useful if you need to access the actual selection made by `select(mediaOption:for:)` for `.automatic`
    /// and `.off` options (forced options might be returned where applicable).
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> CastMediaSelectionOption {
        switch characteristic {
        case .audible, .legible:
            guard let track = _activeTracks.first(where: { $0.mediaCharacteristic == characteristic }) else { return .off }
            return .on(track)
        default:
            return .off
        }
    }
}

extension CastPlayer {
    static func mediaSelectionCharacteristics(from mediaStatus: GCKMediaStatus?) -> Set<AVMediaCharacteristic> {
        Set(tracks(from: mediaStatus).compactMap(\.mediaCharacteristic))
    }

    private static func tracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let rawTracks = mediaStatus?.mediaInformation?.mediaTracks else { return [] }
        return rawTracks.map { .init(rawTrack: $0) }
    }

    static func mediaSelectionOptions(from mediaStatus: GCKMediaStatus?, for characteristic: AVMediaCharacteristic) -> [CastMediaSelectionOption] {
        let tracks = tracks(from: mediaStatus).filter { $0.mediaCharacteristic == characteristic }
        switch characteristic {
        case .audible where tracks.count > 1:
            return tracks.map { .on($0) }
        case .legible where !tracks.isEmpty:
            return [.off] + tracks.map { .on($0) }
        default:
            return []
        }
    }

    private static func mediaOption(
        from mediaStatus: GCKMediaStatus?,
        matchingPreferredLanguages languages: [String],
        for characteristic: AVMediaCharacteristic
    ) -> CastMediaSelectionOption? {
        let options = mediaSelectionOptions(from: mediaStatus, for: characteristic)
        return languages.lazy.compactMap { language in
            options.first { $0.hasLanguageCode(language) }
        }.first
    }

    @discardableResult
    func applyMediaSelectionPreferredLanguages(with mediaStatus: GCKMediaStatus?) -> Bool {
        let characteristics = Self.mediaSelectionCharacteristics(from: mediaStatus)
        guard !characteristics.isEmpty else { return false }
        characteristics.forEach { characteristic in
            if let languages = mediaSelectionPreferredLanguages[characteristic],
               let option = Self.mediaOption(from: mediaStatus, matchingPreferredLanguages: languages, for: characteristic) {
                select(mediaOption: option, for: characteristic)
            }
            else {
                select(mediaOption: .off, for: characteristic)
            }
        }
        return true
    }
}
