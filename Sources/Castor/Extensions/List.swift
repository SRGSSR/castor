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
    /// Binds an item to a media queue.
    ///
    /// - Parameters:
    ///   - currentItemId: The current item id binding.
    ///   - mediaQueue: The media queue.
    func bind(_ currentItemId: Binding<SelectionValue?>, to mediaQueue: MediaQueue) -> some View {
        onChange(of: currentItemId.wrappedValue) { itemId in
            if let itemId {
                mediaQueue.jump(to: itemId)
            }
        }
        .onChange(of: mediaQueue.currentItem) { item in
            currentItemId.wrappedValue = item?.id
        }
        .onAppear {
            currentItemId.wrappedValue = mediaQueue.currentItem?.id
        }
    }
}
