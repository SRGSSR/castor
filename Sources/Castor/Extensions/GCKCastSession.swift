//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKCastSession {
    static func canMute(for session: GCKCastSession?) -> Bool {
        guard let traits = session?.traits else { return false }
        return traits.supportsMuting
    }

    static func canAdjustVolume(for session: GCKCastSession?) -> Bool {
        guard let traits = session?.traits else { return false }
        return !traits.isFixedVolume()
    }

    static func volumeRange(for session: GCKCastSession?) -> ClosedRange<Float> {
        guard let traits = session?.traits else { return 0...0 }
        return traits.volumeRange
    }
}
