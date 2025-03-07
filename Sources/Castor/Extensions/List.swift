//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension List where SelectionValue == CastDevice {
    /// Binds a device state to a cast context.
    ///
    /// - Parameters:
    ///   - device: The device binding.
    ///   - cast: The cast context.
    func bind(_ device: Binding<CastDevice?>, to cast: Cast) -> some View {
        onChange(of: device.wrappedValue) { newDevice in
            if let newDevice {
                cast.startSession(with: newDevice)
            }
        }
        .onChange(of: cast.device) { newDevice in
            device.wrappedValue = newDevice
        }
        .onAppear {
            device.wrappedValue = cast.device
        }
    }
}
