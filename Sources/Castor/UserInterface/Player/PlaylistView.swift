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
            image()
            Text(title)
        }
        .onAppear(perform: item.fetch)
        .redacted(!item.isFetched)
    }

    private var title: String {
        guard item.isFetched else { return .placeholder(length: .random(in: 20...30)) }
        return item.metadata?.title ?? "Untitled"
    }

    private func image() -> some View {
        ArtworkImage(url: item.metadata?.imageUrl())
            .frame(height: 45)
    }
}

struct PlaylistView: View {
    @ObservedObject var player: CastPlayer
    @State private var isSelectionPresented = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar()
            list()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toolbar() -> some View {
        HStack {
            previousButton()
            Spacer()
            managementButtons()
            Spacer()
            nextButton()
        }
        .padding()
    }

    private func list() -> some View {
        ZStack {
            if !player.items.isEmpty {
                List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
                    ItemCell(item: item)
                }
            }
        }
        .animation(.linear, value: player.items)
    }
}

private extension PlaylistView {
    func previousButton() -> some View {
        Button(action: player.returnToPrevious) {
            Image(systemName: "arrow.left")
        }
        .disabled(!player.canReturnToPrevious())
    }

    func managementButtons() -> some View {
        HStack(spacing: 30) {
            repeatModeButton()
            shuffleButton()
        }
        .padding()
    }

    func nextButton() -> some View {
        Button(action: player.advanceToNext) {
            Image(systemName: "arrow.right")
        }
        .disabled(!player.canAdvanceToNext())
    }
}

private extension PlaylistView {
    private var repeatModeImageName: String {
        switch player.repeatMode {
        case .off:
            "repeat.circle"
        case .one:
            "repeat.1.circle.fill"
        case .all:
            "repeat.circle.fill"
        }
    }

    private func toggleRepeatMode() {
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
}
