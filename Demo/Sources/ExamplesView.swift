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
            List {
                section("HLS streams", medias: kHlsUrlMedias)
                if cast.player != nil {
                    section("DASH streams", medias: kDashUrlMedias)
                    if UserDefaults.standard.receiver == .srgssr {
                        section("URN-based streams", medias: kUrnMedias)
                    }
                }
            }
            if cast.player != nil {
                CastMiniMediaControlsView()
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
            PlayerView(media: media)
        }
        .navigationTitle("Examples")
    }

    private func button(for media: Media) -> some View {
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

    private func section(_ titleKey: LocalizedStringKey, medias: [Media]) -> some View {
        Section(titleKey) {
            ForEach(medias) { media in
                button(for: media)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExamplesView()
    }
    .environmentObject(Cast())
}
