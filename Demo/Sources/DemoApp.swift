//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFAudio
import Castor
import GoogleCast
import SwiftUI

private final class AppDelegate: NSObject, UIApplicationDelegate {
    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        configureGoogleCast()
        return true
    }

    private func configureGoogleCast() {
        let criteria = GCKDiscoveryCriteria(applicationID: UserDefaults.standard.receiver.identifier)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
    }
}

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    ExamplesView()
                }
                .tabItem {
                    Label("Examples", systemImage: "film.fill")
                }
                NavigationStack {
                    DevicesView()
                }
                .tabItem {
                    Label("Devices", systemImage: "tv.badge.wifi.fill")
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
        }
        .environmentObject(Cast())
    }
}
