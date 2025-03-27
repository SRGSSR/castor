//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import SwiftUI

struct StreamsView: View {
    @State private var selectedStream: Stream?
    @EnvironmentObject private var cast: Cast

    var body: some View {
        VStack(spacing: 0) {
            List(kStreams) { stream in
                Button {
                    if let player = cast.player {
                        player.queue.loadItems(from: [stream.asset()])
                    }
                    else {
                        selectedStream = stream
                    }
                } label: {
                    Text(stream.title)
                }
            }
            if cast.player != nil {
                MiniMediaControlsView()
                    .frame(height: 64)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.linear(duration: 0.2), value: cast.player)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: batchLoad) {
                    Text("Load > 20")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: append) {
                    Text("Append")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                CastButton()
            }
        }
        .sheet(item: $selectedStream) { stream in
            PlayerView(url: stream.url)
        }
        .navigationTitle("Castor")
    }

    private func batchLoad() {
        guard let player = cast.player else { return }
        player.queue.loadItems(from: (kStreams + kStreams + kStreams + kStreams).map { $0.asset() })
    }

    private func append() {
        guard let player = cast.player, let stream = kStreams.randomElement() else { return }
        player.queue.appendItems(from: [stream.asset()])
    }
}

#Preview {
    NavigationStack {
        StreamsView()
    }
}
