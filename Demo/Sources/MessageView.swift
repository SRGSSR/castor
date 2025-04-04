//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

enum MessageIcon {
    case none
    case error
    case empty
    case system(String)

    var systemName: String? {
        switch self {
        case .none:
            return nil
        case .error:
            return "exclamationmark.bubble"
        case .empty:
            return "circle.slash"
        case let .system(name):
            return name
        }
    }
}

struct MessageView: View {
    let message: String
    let icon: MessageIcon
    let description: String?

    var body: some View {
        VStack(spacing: 16) {
            if let systemName = icon.systemName {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.secondary)
                    .frame(height: 40)
            }
            infoView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    init(message: String, icon: MessageIcon, description: String? = nil) {
        self.message = message
        self.icon = icon
        self.description = description
    }

    private func infoView() -> some View {
        VStack(spacing: 4) {
            Text(message)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            if let description {
                Text(description)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("None") {
    MessageView(message: "No items", icon: .none)
}

#Preview("Error") {
    MessageView(message: "No items", icon: .error)
}

#Preview("Empty") {
    MessageView(message: "No items", icon: .empty)
}

#Preview("System") {
    MessageView(message: "Not connected", icon: .system("wifi"))
}

#Preview("Message") {
    MessageView(message: "No items", icon: .system("circle.slash"), description: "Please buy some items")
}
