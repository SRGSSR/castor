//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct RootView: View {
    @StateObject private var cast = Cast(configuration: .standard)
    @StateObject private var router = Router()

    @AppStorage(UserDefaults.DemoSettingKey.playerType)
    private var playerType: PlayerType = .standard

    var body: some View {
        TabView {
            examplesTab()
            settingsTab()
        }
        .sheet(item: $router.presented) { destination in
            destination.view()
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
        if cast.player != nil {
            CastMiniPlayerView(cast: cast)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onTapGesture(perform: showPlayer)
                .accessibilityAddTraits(.isButton)
                .background(.thickMaterial)
                .frame(height: 64)
        }
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

#Preview {
    RootView()
}
