//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// State information useful when transitioning between remote and local playback.
public struct CastResumeState {
    /// The assets.
    public let assets: [CastAsset]

    /// The current index.
    public let index: Int

    /// The current time.
    ///
    /// An `.invalid` time corresponds to the default playback position.
    public let time: CMTime

    private var mediaSelectionLanguages: [AVMediaCharacteristic: String] = [:]

    /// Creates a state.
    ///
    /// - Parameters:
    ///   - assets: The assets.
    ///   - index: The current index.
    ///   - time: The current time. Use `.invalid` for the default playback position.
    ///
    /// Fails if no valid index into the asset list is provided.
    public init?(assets: [CastAsset], index: Int?, time: CMTime) {
        guard let index, assets.indices.contains(index) else { return nil }
        self.assets = assets
        self.index = index
        self.time = time
    }
}

public extension CastResumeState {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        Set(mediaSelectionLanguages.keys)
    }

    /// Sets the media selection language for the specified media characteristic.
    ///
    /// - Parameters:
    ///   - language: The code of the selected language.
    ///   - characteristic: The media characteristic for which the selection criteria are to be applied. Supported values
    ///     include `.audible` and `.legible`.
    mutating func setMediaSelection(language: String?, for characteristic: AVMediaCharacteristic) {
        mediaSelectionLanguages[characteristic] = language
    }

    /// Returns the media selection language for the specified media characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    func mediaSelectionLanguage(for characteristic: AVMediaCharacteristic) -> String? {
        mediaSelectionLanguages[characteristic]
    }
}
