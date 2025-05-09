//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct ItemCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            image()
            Text(title)
        }
        .onAppear(perform: item.fetch)
        .redactedIfNil(item.metadata)
    }

    private var title: String {
        guard let metadata = item.metadata else { return .placeholder(length: .random(in: 20...30)) }
        return metadata.title ?? "-"
    }

    private func image() -> some View {
        AsyncImage(url: item.metadata?.imageUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(width: 80, height: 45)
    }
}

struct PlaylistView: View {
    @ObservedObject var player: CastPlayer
    @ObservedObject var queue: CastQueue
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
            if !queue.items.isEmpty {
                List($queue.items, id: \.self, editActions: .all, selection: queue.currentItemSelection) { $item in
                    ItemCell(item: item)
                }
            }
            else {
                MessageView(message: "No items", icon: .none)
            }
        }
        .animation(.linear, value: queue.items)
    }
}

private extension PlaylistView {
    func previousButton() -> some View {
        Button(action: queue.returnToPreviousItem) {
            Image(systemName: "arrow.left")
        }
        .disabled(!queue.canReturnToPreviousItem())
    }

    func managementButtons() -> some View {
        HStack(spacing: 30) {
            repeatModeButton()
            shuffleButton()
            addButton()
            trashButton()
        }
        .padding()
    }

    func nextButton() -> some View {
        Button(action: queue.advanceToNextItem) {
            Image(systemName: "arrow.right")
        }
        .disabled(!queue.canAdvanceToNextItem())
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
    }
}

private extension PlaylistView {
    func shuffleButton() -> some View {
        Button {
            queue.items.shuffle()
        } label: {
            Image(systemName: "shuffle")
        }
        .disabled(queue.isEmpty)
    }

    func addButton() -> some View {
        Button {
            isSelectionPresented.toggle()
        } label: {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView(queue: queue)
            }
        }
    }

    func trashButton() -> some View {
        Button(action: queue.removeAllItems) {
            Image(systemName: "trash")
        }
        .disabled(queue.isEmpty)
    }
}
