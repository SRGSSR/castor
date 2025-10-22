//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A Cast receiver.
public protocol CastReceiver {
    /// The receiver's friendly name.
    var name: String? { get }
}

extension CastReceiver {
    static func name(for device: CastReceiver?) -> String {
        device?.name ?? String(localized: "Unknown", bundle: .module, comment: "Generic name for a Cast device")
    }
}
