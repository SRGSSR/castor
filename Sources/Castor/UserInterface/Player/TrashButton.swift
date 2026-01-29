//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct TrashButton: View {
    @ObservedObject var player: CastPlayer
    let style: ButtonStyle

    @State private var isPresented = false

    private var label: LocalizedStringResource {
        LocalizedStringResource("Delete all", bundle: .module, comment: "Button to delete all items from a playlist")
    }

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            ZStack {
                switch style {
                case .large:
                    Label {
                        Text(label)
                    } icon: {
                        Image(systemName: "trash")
                    }
                    .fixedSize()
                case .compact:
                    Image(systemName: "trash")
                }
                PlaylistToolbar.largestShape()
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(label)
        .disabled(player.items.isEmpty)
        .confirmationDialog(
            Text("All items in the playlist will be deleted.", bundle: .module, comment: "Message warning the user before deleting all items in a playlist"),
            isPresented: $isPresented,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                player.removeAllItems()
            } label: {
                Text("Delete all Items", bundle: .module, comment: "Title of the confirmation dialog displayed before deleting all items in a playlist")
            }
        }
    }
}
