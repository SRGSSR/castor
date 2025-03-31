//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct PlaylistView: View {
    @ObservedObject var queue: CastQueue
    @State private var isSelectionPresented = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar()
            list()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func list() -> some View {
        ZStack {
            if !queue.items.isEmpty {
                List($queue.items, id: \.self, editActions: .all, selection: queue.currentItemSelection) { $item in
                    ItemCell(item: item)
                }
            }
            else {
                ContentUnavailableView {
                    Text("No items")
                }
            }
        }
        .animation(.linear, value: queue.items)
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

    private func previousButton() -> some View {
        Button(action: queue.returnToPreviousItem) {
            Image(systemName: "arrow.left")
        }
        .disabled(!queue.canReturnToPreviousItem())
    }

    private func managementButtons() -> some View {
        HStack(spacing: 30) {
            Button(action: shuffle) {
                Image(systemName: "shuffle")
            }
            .disabled(queue.isEmpty)

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

            Button(action: queue.removeAllItems) {
                Image(systemName: "trash")
            }
            .disabled(queue.isEmpty)
        }
        .padding()
    }

    private func nextButton() -> some View {
        Button(action: queue.advanceToNextItem) {
            Image(systemName: "arrow.right")
        }
        .disabled(!queue.canAdvanceToNextItem())
    }

    private func shuffle() {
        queue.items.shuffle()
    }
}

private struct ItemCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            AsyncImage(url: item.metadata?.imageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 64, height: 64)

            Text(title)
                .onAppear(perform: item.fetch)
                .redactedIfNil(item.metadata)
        }
    }

    private var title: String {
        guard let metadata = item.metadata else { return .placeholder(length: .random(in: 20...30)) }
        return metadata.title ?? "-"
    }
}
