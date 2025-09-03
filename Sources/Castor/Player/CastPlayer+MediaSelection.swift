//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast
import SwiftUI

public extension CastPlayer {
    /// The set of media characteristics that have an available media selection.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        Self.mediaSelectionCharacteristics(from: _mediaStatus)
    }

    /// Returns the list of media options associated with a given characteristic.
    ///
    /// - Parameter characteristic: The media characteristic to query.
    /// - Returns: The list of options available for the specified characteristic.
    ///
    /// Use `mediaSelectionCharacteristics` to retrieve the available characteristics.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [CastMediaSelectionOption] {
        Self.mediaSelectionOptions(from: _mediaStatus, for: characteristic)
    }

    /// Returns the currently selected media option for a given characteristic.
    ///
    /// - Parameter characteristic: The media characteristic to query.
    /// - Returns: The currently selected option.
    ///
    /// Use `mediaSelectionCharacteristics` to retrieve the available characteristics.
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

    /// A binding to read and update the current media selection for a given characteristic.
    ///
    /// - Parameter characteristic: The media characteristic to bind.
    /// - Returns: A binding representing the current selection.
    func mediaOption(for characteristic: AVMediaCharacteristic) -> Binding<CastMediaSelectionOption> {
        .init {
            self.selectedMediaOption(for: characteristic)
        } set: { newValue in
            self.select(mediaOption: newValue, for: characteristic)
        }
    }

    /// Returns the current media option applied for a given characteristic.
    ///
    /// - Parameter characteristic: The media characteristic to query.
    /// - Returns: The currently applied option.
    ///
    /// Unlike `selectedMediaOption(for:)`, this method reflects the actual selection applied by
    /// `select(mediaOption:for:)`, including `.automatic` and `.off` options.
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> CastMediaSelectionOption {
        switch characteristic {
        case .audible, .legible:
            guard let track = _activeTracks.first(where: { $0.mediaCharacteristic == characteristic }) else { return .off }
            return .on(track)
        default:
            return .off
        }
    }

    /// Sets the preferred media selection for a specified media characteristic.
    ///
    /// - Parameters:
    ///   - preference: The preference to apply.
    ///   - characteristic: The media characteristic to configure. Supported values include `.audible` and `.legible`.
    ///
    /// Use this method to override the default media option selection, for example, to start playback
    /// with a predefined audio or subtitle language.
    ///
    /// > Note: The media selection preference applies only to the first content played in a session.
    func setMediaSelectionPreference(_ preference: CastMediaSelectionPreference, for characteristic: AVMediaCharacteristic) {
        switch preference.kind {
        case .off:
            mediaSelectionPreferredLanguages.removeValue(forKey: characteristic)
        case let .on(languages: languages):
            mediaSelectionPreferredLanguages[characteristic] = languages
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
