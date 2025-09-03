//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// The configuration associated with a URL-based asset.
public struct CastAssetURLConfiguration {
    /// The MIME type of the asset.
    public let mimeType: String?

    /// The audio segment format (HLS streams only).
    public let hlsAudioSegmentFormat: GCKHLSSegmentFormat

    /// The video segment format (HLS streams only).
    public let hlsVideoSegmentFormat: GCKHLSVideoSegmentFormat

    /// Creates a configuration for a URL-based asset.
    ///
    /// - Parameters:
    ///   - mimeType: The MIME type of the asset.
    ///   - hlsAudioSegmentFormat: The audio segment format (HLS streams only).
    ///   - hlsVideoSegmentFormat: The video segment format (HLS streams only).
    public init(
        mimeType: String? = nil,
        hlsAudioSegmentFormat: GCKHLSSegmentFormat = .undefined,
        hlsVideoSegmentFormat: GCKHLSVideoSegmentFormat = .undefined
    ) {
        self.mimeType = mimeType
        self.hlsAudioSegmentFormat = hlsAudioSegmentFormat
        self.hlsVideoSegmentFormat = hlsVideoSegmentFormat
    }
}
