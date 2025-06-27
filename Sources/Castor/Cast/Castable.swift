//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Methods that an object adopts to provide cast related information.
public protocol Castable: AnyObject {
    /// The assets to send to the receiver.
    ///
    /// - Returns: A list of assets to be cast.
    func assets() -> [CastAsset]
}
