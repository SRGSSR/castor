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
    @Namespace private var namespace

    var body: some View {
        TabView {
            NavigationStack {
                ExamplesView()
                    .safeAreaInsetMiniPlayer(for: cast, in: namespace)
            }
            .tabItem {
                Label("Examples", systemImage: "film.fill")
            }
            NavigationStack {
                CastPlayerView()
            }
            .tabItem {
                Label("Player", systemImage: "play.rectangle.fill")
            }
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .sheet(item: $router.presented) { destination in
            destination.view()
                .zoomNavigationTransition18(sourceID: TransitionId.zoom, in: namespace)
        }
        .tabViewBottomAccessoryMiniPlayer26(for: cast, in: namespace)
        // TODO: Starting with iOS 17 this can be moved on the `WindowGroup` without the need for a local `@State`.
        .environmentObject(cast)
        .environmentObject(router)
        .supportsCast(cast, with: router)
    }
}

#Preview {
    RootView()
}
