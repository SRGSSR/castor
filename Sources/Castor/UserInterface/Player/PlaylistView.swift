//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private enum ButtonStyle {
    case large
    case small
}

private struct ItemCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            artworkImage()
            Text(title)
                .redacted(!item.isFetched)
            Spacer()
            disclosureImage()
        }
        .onAppear(perform: item.fetch)
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
    @State private var isDeleteAllPresented = false

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
            .buttonStyle(.bordered)
    }
}

private extension PlaylistView {
    func managementButtons() -> some View {
        ViewThatFits {
            HStack {
                repeatModeButton(style: .large)
                shuffleButton(style: .large)
                trashButton(style: .large)
            }
            HStack {
                repeatModeButton(style: .small)
                shuffleButton(style: .small)
                trashButton(style: .small)
            }
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
}

private extension PlaylistView {
    func repeatModeButton(style: ButtonStyle) -> some View {
        Button(action: toggleRepeatMode) {
            Group {
                switch style {
                case .large:
                    Label("Repeat", systemImage: repeatModeImageName)
                        .fixedSize()
                case .small:
                    Image(systemName: repeatModeImageName)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!player.isActive)
    }

    func shuffleButton(style: ButtonStyle) -> some View {
        Button {
            player.items.shuffle()
        } label: {
            Group {
                switch style {
                case .large:
                    Label("Shuffle", systemImage: "shuffle")
                        .fixedSize()
                case .small:
                    Image(systemName: "shuffle")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(player.items.isEmpty)
    }

    func trashButton(style: ButtonStyle) -> some View {
        Button {
            isDeleteAllPresented.toggle()
        } label: {
            Group {
                switch style {
                case .large:
                    Label("Delete all", systemImage: "trash")
                        .fixedSize()
                case .small:
                    Image(systemName: "trash")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(player.items.isEmpty)
        .confirmationDialog("All items in the playlist will be deleted.", isPresented: $isDeleteAllPresented, titleVisibility: .visible) {
            Button(role: .destructive) {
                player.removeAllItems()
            } label: {
                Text("Delete all Items")
            }
        }
    }
}
