//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import SwiftUI

struct ExamplesView: View {
    @State private var selectedMedia: Media?
    @EnvironmentObject private var cast: Cast

    var body: some View {
        VStack(spacing: 0) {
            List(kUrlMedias) { media in
                Button {
                    if let player = cast.player {
                        player.queue.loadItem(from: media.asset())
                    }
                    else {
                        selectedMedia = media
                    }
                } label: {
                    Text(media.title)
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
            ToolbarItem(placement: .topBarTrailing) {
                CastButton()
            }
        }
        .sheet(item: $selectedMedia) { media in
            PlayerView(url: media.url)
        }
        .navigationTitle("Examples")
    }
}

#Preview {
    NavigationStack {
        ExamplesView()
    }
}
