//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct ItemCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            artworkImage()
            Text(title)
            Spacer()
            disclosureImage()
        }
        .onAppear(perform: item.fetch)
        .redacted(!item.isFetched)
    }

    private var title: String {
        guard item.isFetched else { return .placeholder(length: .random(in: 20...30)) }
        return item.metadata?.title ?? "Untitled"
    }

    private func artworkImage() -> some View {
        ArtworkImage(url: item.metadata?.imageUrl())
            .frame(height: 45)
    }

    private func disclosureImage() -> some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
    }
}

struct PlaylistView: View {
    @ObservedObject var player: CastPlayer
    @State private var isSelectionPresented = false

    var body: some View {
        VStack {
            if !player.items.isEmpty {
                toolbar()
                List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
                    ItemCell(item: item)
                }
                .listStyle(.plain)
            }
            else {
                UnavailableView("No items", systemImage: "list.bullet")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.linear, value: player.items)
    }

    private func toolbar() -> some View {
        managementButtons()
            .frame(maxWidth: .infinity)
    }
}

private extension PlaylistView {
    func managementButtons() -> some View {
        HStack(spacing: 30) {
            repeatModeButton()
            shuffleButton()
            trashButton()
        }
        .padding()
    }
}

private extension PlaylistView {
    var repeatModeImageName: String {
        switch player.repeatMode {
        case .off:
            "repeat.circle"
        case .one:
            "repeat.1.circle.fill"
        case .all:
            "repeat.circle.fill"
        }
    }

    func toggleRepeatMode() {
        switch player.repeatMode {
        case .off:
            player.repeatMode = .all
        case .one:
            player.repeatMode = .off
        case .all:
            player.repeatMode = .one
        }
    }

    func repeatModeButton() -> some View {
        Button(action: toggleRepeatMode) {
            Image(systemName: repeatModeImageName)
        }
        .disabled(!player.isActive)
    }
}

private extension PlaylistView {
    func shuffleButton() -> some View {
        Button {
            player.items.shuffle()
        } label: {
            Image(systemName: "shuffle")
        }
        .disabled(player.items.isEmpty)
    }

    func trashButton() -> some View {
        Button {
            player.removeAllItems()
        } label: {
            Image(systemName: "trash")
        }
        .disabled(player.items.isEmpty)
    }
}
