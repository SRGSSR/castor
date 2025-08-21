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

    @AppStorage(UserDefaults.DemoSettingKey.playerType)
    private var playerType: PlayerType = .standard

    var body: some View {
        List {
            section("HLS URLs", medias: kHlsUrlMedias)
            section("MP3 URLs ", medias: kMP3UrlMedias)
            if cast.player != nil {
                section("DASH URLs", medias: kDashUrlMedias)
            }
            if UserDefaults.standard.receiver.isSrgSsrReceiver {
                section("URNs", medias: kUrnMedias)
            }
        }
        .animation(.linear(duration: 0.2), value: cast.player)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CastButton(cast: cast)
            }
        }
        .navigationTitle("Examples")
    }

    private func button(for media: Media) -> some View {
        Button {
            showPlayer(for: media)
        } label: {
            Text(media.title)
        }
    }

    private func showPlayer(for media: Media) {
        if let player = cast.player {
            player.loadItem(from: media.asset())
        }
        else {
            switch playerType {
            case .standard:
                router.presented = .localPlayer(media: media)
            case .unified:
                router.presented = .unifiedPlayer(media: media)
            }
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
