//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct MiniPlayer: View {
    @ObservedObject var player: CastPlayer

    @EnvironmentObject private var cast: Cast
    @EnvironmentObject private var router: Router

    @AppStorage(UserDefaults.DemoSettingKey.playerType)
    private var playerType: PlayerType = .standard

    var body: some View {
        ZStack {
            if isLoaded {
                CastMiniPlayerView(cast: cast)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.thickMaterial)
                    .onTapGesture(perform: showPlayer)
                    .accessibilityAddTraits(.isButton)
                    .frame(height: 64)
                    .geometryGroup17()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.default, value: isLoaded)
    }

    private var isLoaded: Bool {
        !player.items.isEmpty
    }

    private func showPlayer() {
        switch playerType {
        case .standard:
            router.presented = .remotePlayer
        case .unified:
            router.presented = .unifiedPlayer
        }
    }
}

struct RootView: View {
    @StateObject private var cast = Cast(configuration: .standard)
    @StateObject private var router = Router()

    var body: some View {
        TabView {
            examplesTab()
            settingsTab()
        }
        .sheet(item: $router.presented) { destination in
            destination.view()
                .environmentObject(cast) // FIXME: Only needed when the app is running on macOS (Designed for iPad).
        }
        // TODO: Starting with iOS 17 this can be moved on the `DemoApp` window group.
        .environmentObject(cast)
        .environmentObject(router)
        .supportsCast(cast, with: router)
    }

    private func examplesTab() -> some View {
        NavigationStack {
            ExamplesView()
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    miniPlayer()
                }
        }
        .tabItem {
            Label("Examples", systemImage: "film.fill")
        }
    }

    private func settingsTab() -> some View {
        NavigationStack {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }

    @ViewBuilder
    private func miniPlayer() -> some View {
        if let player = cast.player {
            MiniPlayer(player: player)
        }
    }
}

#Preview {
    RootView()
}
