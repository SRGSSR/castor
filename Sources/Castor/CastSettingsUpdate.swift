//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A settings update.
public enum CastSettingsUpdate {
    /// Playback speed.
    case playbackSpeed(Float)

    /// Media selection.
    case mediaSelection(characteristic: AVMediaCharacteristic, option: CastMediaSelectionOption)
}
