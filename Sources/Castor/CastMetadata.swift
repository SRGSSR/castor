//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

public struct CastMetadata {
    let rawMetadata: GCKMediaMetadata

    public init(title: String?) {
        rawMetadata = GCKMediaMetadata()
        if let title {
            rawMetadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }
    }
}
