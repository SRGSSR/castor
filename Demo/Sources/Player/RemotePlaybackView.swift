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
            Text(title)
            Spacer()
            disclosureImage()
        }
        .onAppear(perform: item.fetch)
    }

    private var title: String {
        guard item.isFetched else { return "" }
        return item.metadata?.title ?? "Untitled"
    }

    private func disclosureImage() -> some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
    }
}

struct RemotePlaybackView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        VStack(spacing: 0) {
            mainView()
            playlistView()
        }
    }

    private func mainView() -> some View {
        ZStack {
            artwork()
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func playlistView() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            ItemCell(item: item)
        }
    }

    private func artwork() -> some View {
        AsyncImage(url: player.metadata?.imageUrl()) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            EmptyView()
        }
    }
}
