//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaylistView: View {
    @ObservedObject var player: CastPlayer
    @State private var isSelectionPresented = false

    var body: some View {
        VStack(spacing: 0) {
            PlaylistToolbar(player: player)
            list()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: player.items)
    }

    private func list() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            ItemCell(item: item)
        }
        .listStyle(.plain)
        .applyInnerMask(height: 5)
    }
}

private extension View {
    func applyInnerMask(height: CGFloat) -> some View {
        safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: height)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: height)
        }
        .overlay {
            VStack {
                LinearGradient(colors: [Color(.systemBackground), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: height)
                Spacer()
                LinearGradient(colors: [.clear, Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
                    .frame(height: height)
            }
            .ignoresSafeArea()
        }
    }
}
