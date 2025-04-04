//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.DemoSettingKey.presenterModeEnabled)
    private var isPresenterModeEnabled = false

    @AppStorage(UserDefaults.DemoSettingKey.receiver)
    private var receiver: Receiver = .standard

    private var version: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    private var buildVersion: String {
        Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }

    private var applicationIdentifier: String? {
        let applicationIdentifier = Bundle.main.infoDictionary!["TestFlightApplicationIdentifier"] as! String
        return !applicationIdentifier.isEmpty ? applicationIdentifier : nil
    }

    var body: some View {
        Form {
            applicationSection()
            receiverSection()
            versionSection()
        }
        .onChange(of: receiver) { _ in exit(0) }
        .navigationTitle("Settings")
    }

    private func applicationSection() -> some View {
        Section {
            Toggle(isOn: $isPresenterModeEnabled) {
                Text("Presenter mode")
                Text("Displays touches for presentation purposes.").font(.footnote)
            }
        } header: {
            Text("Application")
        }
    }

    private func receiverSection() -> some View {
        Section {
            Picker(selection: $receiver) {
                ForEach(Receiver.allCases, id: \.self) { receiver in
                    Text(receiver.name)
                        .tag(receiver)
                }
            } label: {
                Text("Receiver")
                Text("Updating this setting will exit the application.")
                    .font(.footnote)
            }
        }
    }

    private func versionSection() -> some View {
        Section {
            LabeledContent("Application", value: "\(version), build \(buildVersion)")
            LabeledContent("Library", value: Cast.version)
            if let applicationIdentifier {
                Button("TestFlight builds") {
                    openTestFlight(forApplicationIdentifier: applicationIdentifier)
                }
            }
        } header: {
            Text("Version information")
        } footer: {
            versionFooter()
        }
    }

    private func versionFooter() -> some View {
        HStack(spacing: 0) {
            Text("Made with ")
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .pulseSymbolEffect17()
            Text(" in Switzerland")
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement()
        .accessibilityLabel("Made with love in Switzerland")
    }
}

private extension SettingsView {
    static func testFlightUrl(forApplicationIdentifier applicationIdentifier: String) -> URL? {
        var url = URL("itms-beta://beta.itunes.apple.com/v1/app/")
            .appending(path: applicationIdentifier)
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }

    func openTestFlight(forApplicationIdentifier applicationIdentifier: String?) {
        guard let applicationIdentifier, let url = Self.testFlightUrl(forApplicationIdentifier: applicationIdentifier) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

#Preview {
    SettingsView()
}
