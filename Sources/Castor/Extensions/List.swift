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

public extension List where SelectionValue == CastPlayerItem {
    /// Binds an item to a media queue.
    ///
    /// - Parameters:
    ///   - currentItem: The current item binding.
    ///   - mediaQueue: The media queue.
    func bind(_ currentItem: Binding<CastPlayerItem?>, to mediaQueue: MediaQueue) -> some View {
        onChange(of: currentItem.wrappedValue) { _ in
            // TODO: Jump to the item!
        }
        .onChange(of: mediaQueue.currentItem) { item in
            currentItem.wrappedValue = item
        }
        .onAppear {
            currentItem.wrappedValue = mediaQueue.currentItem
        }
    }
}
