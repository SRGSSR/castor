//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// State information useful for transitioning between remote and local playback.
public struct CastResumeState {
    /// The assets in the queue.
    public let assets: [CastAsset]

    public let options: CastLoadOptions

    private var mediaSelectionLanguages: [AVMediaCharacteristic: String] = [:]

    /// Creates a state.
    ///
    /// - Parameters:
    ///   - assets: The assets in the queue.
    ///   - index: The current index in the asset list.
    ///   - time: The current playback time. Use `.invalid` for the default position.
    ///
    /// Fails if the provided index is not valid for the asset list.
    public init?(assets: [CastAsset], options: CastLoadOptions) {
        guard assets.indices.contains(options.startIndex) else { return nil }
        self.assets = assets
        self.options = options
    }
}

public extension CastResumeState {
    /// The set of media characteristics that have an available media selection.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        Set(mediaSelectionLanguages.keys)
    }

    /// Sets the media selection language for a specified media characteristic.
    ///
    /// - Parameters:
    ///   - language: The language code to select, specified using RFC 1766 tags.
    ///   - characteristic: The media characteristic to configure. Supported values include `.audible` and `.legible`.
    mutating func setMediaSelection(language: String?, for characteristic: AVMediaCharacteristic) {
        mediaSelectionLanguages[characteristic] = language
    }

    /// Returns the media selection language for a given media characteristic.
    ///
    /// - Parameter characteristic: The media characteristic to query.
    func mediaSelectionLanguage(for characteristic: AVMediaCharacteristic) -> String? {
        mediaSelectionLanguages[characteristic]
    }
}
