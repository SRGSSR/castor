//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// The configuration associated with a URL asset.
public struct CastAssetURLConfiguration {
    /// The MIME type.
    public let mimeType: String?

    /// The audio segment format (HLS only).
    public let hlsAudioSegmentFormat: GCKHLSSegmentFormat

    /// The video segment format (HLS only).
    public let hlsVideoSegmentFormat: GCKHLSVideoSegmentFormat

    /// Creates a configuration associated with a URL asset.
    ///
    /// - Parameters:
    ///   - mimeType: The MIME type.
    ///   - hlsAudioSegmentFormat: The audio segment format (HLS only).
    ///   - hlsVideoSegmentFormat: The video segment format (HLS only).
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
