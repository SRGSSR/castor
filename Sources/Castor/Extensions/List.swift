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
    func bind(_ currentDevice: Binding<CastDevice?>, to cast: Cast) -> some View {
        onChange(of: currentDevice.wrappedValue) { device in
            if let device {
                cast.startSession(with: device)
            }
        }
        .onChange(of: cast.currentDevice) { device in
            currentDevice.wrappedValue = device
        }
        .onAppear {
            currentDevice.wrappedValue = cast.currentDevice
        }
    }
}

public extension List where SelectionValue == CastPlayerItem.ID {
    /// Binds an item to a queue.
    ///
    /// - Parameters:
    ///   - currentItemId: The current item id binding.
    ///   - queue: The queue.
    func bind(_ currentItemId: Binding<SelectionValue?>, to queue: CastQueue) -> some View {
        onChange(of: currentItemId.wrappedValue) { itemId in
            if let itemId {
                queue.jump(to: itemId)
            }
        }
        .onChange(of: queue.currentItem?.id) { itemId in
            currentItemId.wrappedValue = itemId
        }
        .onAppear {
            currentItemId.wrappedValue = queue.currentItem?.id
        }
    }
}
