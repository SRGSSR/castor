//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol describing a castable context.
public protocol Castable: AnyObject {
    /// The resume state to send to the receiver.
    func castResumeState() -> CastResumeState?
}
