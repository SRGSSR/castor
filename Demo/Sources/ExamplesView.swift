//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import SwiftUI

struct ExamplesView: View {
    @EnvironmentObject private var cast: Cast
    @EnvironmentObject private var router: Router

    var body: some View {
        List {
            section("HLS streams", medias: kHlsUrlMedias)
            section("MP3 streams ", medias: kMP3UrlMedias)
            if cast.player != nil {
                section("DASH streams", medias: kDashUrlMedias)
            }
            if UserDefaults.standard.receiver.isSupportingUrns {
                section("URN-based streams", medias: kUrnMedias)
            }
        }
        .safeAreaInsetMiniPlayer(for: cast)
        .animation(.linear(duration: 0.2), value: cast.player)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CastButton(cast: cast)
            }
        }
        .toolbarBackgroundVisibilityForTabBar18(cast.player == nil ? .automatic : .hidden)
        .sheet(item: $router.presented) { destination in
            destination.view()
        }
        .navigationTitle("Examples")
    }

    private func button(for media: Media) -> some View {
        Button {
            if let player = cast.player {
                player.loadItem(from: media.asset())
            }
            else {
                router.presented = .player(content: .init(medias: [media]))
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

private extension View {
    @ViewBuilder
    func safeAreaInsetMiniPlayer(for cast: Cast) -> some View {
        if #unavailable(iOS 26) {
            safeAreaInset(edge: .bottom, spacing: 0) {
                if cast.player != nil {
                    CastMiniPlayerView(cast: cast)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.thickMaterial)
                        .frame(height: 64)
                }
            }
        }
        else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        ExamplesView()
    }
    .environmentObject(Cast())
}
