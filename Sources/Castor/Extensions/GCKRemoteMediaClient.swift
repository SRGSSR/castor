//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKRemoteMediaClient {
    func canMakeRequest() -> Bool {
        mediaStatus?.isConnected == true
    }
}
