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

    var body: some View {
        TabView {
            examplesTab()
            playerTab()
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

    private func playerTab() -> some View {
        NavigationStack {
            CastPlayerView()
        }
        .tabItem {
            Label("Player", systemImage: "play.rectangle.fill")
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
            MiniPlayerView(cast: cast)
                .background(.thickMaterial)
                .frame(height: 64)
        }
    }
}

#Preview {
    RootView()
}
