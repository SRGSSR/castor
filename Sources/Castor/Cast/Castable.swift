//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Methods that an object adopts to provide cast related information.
public protocol Castable: AnyObject {
    /// The resume state to send to the receiver.
    func castResumeState() -> CastResumeState?
}
