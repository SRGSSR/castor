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

    private var preferredLanguages: [AVMediaCharacteristic: [String]] = [:]

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
    /// Sets media selection preferred languages for the specified media characteristic.
    ///
    /// - Parameters:
    ///   - languages: An Array of strings containing language identifiers, in order of desirability, that are
    ///     preferred for selection. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T
    ///     language codes.
    ///   - characteristic: The media characteristic for which the selection criteria are to be applied. Supported values
    ///     include `.audible`, `.legible`, and `.visual`.
    mutating func setMediaSelection(preferredLanguages languages: [String], for characteristic: AVMediaCharacteristic) {
        preferredLanguages[characteristic] = languages
    }

    /// Returns media selection preferred languages for the specified media characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    func mediaSelectionPreferredLanguages(for characteristic: AVMediaCharacteristic) -> [String] {
        preferredLanguages[characteristic] ?? []
    }
}
