//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view that displays a Cast icon, reflecting the current connection state.
///
/// > Warning: Adjust the icon size using ``font(_:)``.
public struct CastIcon: View {
    @ObservedObject var cast: Cast

    // swiftlint:disable:next missing_docs
    public var body: some View {
        ZStack {
            switch cast.connectionState {
            case .connecting:
                if #available(iOS 17, *) {
                    castImage(name: "google.cast")
                        .symbolEffect(.variableColor.iterative.reversing)
                }
                else {
                    castImage(name: "google.cast.fill")
                        .symbolRenderingMode(.multicolor)
                }
            case .connected:
                castImage(name: "google.cast.fill")
            default:
                castImage(name: "google.cast")
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }

    /// Creates a Cast icon.
    public init(cast: Cast) {
        self.cast = cast
    }

    private func castImage(name: String) -> some View {
        Image(name, bundle: .module)
    }
}

private extension CastIcon {
    var accessibilityLabel: String {
        switch cast.connectionState {
        case .connecting:
            String(
                localized: "Connecting to \(deviceName)",
                bundle: .module,
                comment: "Cast icon accessibility label when connecting to a receiver device (device name as wildcard)"
            )
        case .connected:
            String(
                localized: "Connected to \(deviceName)",
                bundle: .module,
                comment: "Cast icon accessibility label when connected to a receiver device (device name as wildcard)"
            )
        default:
            String(localized: "Not casting", bundle: .module, comment: "Cast icon accessibility label when not connected to a receiver device")
        }
    }

    private var deviceName: String {
        CastDevice.name(for: cast.currentDevice)
    }
}
