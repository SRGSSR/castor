//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var cast: Cast

    @AppStorage(UserDefaults.DemoSettingKey.presenterModeEnabled)
    private var isPresenterModeEnabled = false

    @AppStorage(UserDefaults.DemoSettingKey.receiver)
    private var receiver: Receiver = .standard

    @AppStorage(UserDefaults.DemoSettingKey.playerType)
    private var playerType: PlayerType = .standard

    @AppStorage(UserDefaults.DemoSettingKey.smartNavigationEnabled)
    private var isSmartNavigationEnabled = true

    @AppStorage(UserDefaults.DemoSettingKey.backwardSkipInterval)
    private var backwardSkipInterval: TimeInterval = 10

    @AppStorage(UserDefaults.DemoSettingKey.forwardSkipInterval)
    private var forwardSkipInterval: TimeInterval = 10

    private var version: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    private var buildVersion: String {
        Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }

    private var applicationIdentifier: String? {
        guard let applicationIdentifier = Bundle.main.infoDictionary?["TestFlightApplicationIdentifier"] as? String else {
            return nil
        }
        return !applicationIdentifier.isEmpty ? applicationIdentifier : nil
    }

    var body: some View {
        Form {
            applicationSection()
            playerSection()
            skipsSection()
            receiverSection()
            debuggingSection()
            linksSection()
            versionSection()
        }
        .onChange(of: receiver) { _ in exit(0) }
        .navigationTitle("Settings")
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            cast.configuration = .standard
        }
    }

    private func applicationSection() -> some View {
        Section {
            Toggle(isOn: $isPresenterModeEnabled) {
                Text("Presenter mode")
                Text("Displays touches for presentation purposes.")
                    .font(.footnote)
            }
            Button(action: openSettings) {
                Text("Open settings")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } header: {
            Text("Application")
        }
    }

    private func playerSection() -> some View {
        Section {
            Picker(selection: $playerType) {
                ForEach(PlayerType.allCases, id: \.self) { playerType in
                    Text(playerType.name)
                        .tag(playerType)
                }
            } label: {
                Text("Type")
            }
            Toggle(isOn: $isSmartNavigationEnabled) {
                Text("Smart navigation")
                Text("Improves playlist navigation so that it feels more natural.")
                    .font(.footnote)
            }
        } header: {
             Text("Player")
        }
    }

    private func skipsSection() -> some View {
        Section {
            skipPicker("Backward by", selection: $backwardSkipInterval)
            skipPicker("Forward by", selection: $forwardSkipInterval)
        } header: {
             Text("Skips")
        }
    }

    private func skipPicker(_ titleKey: LocalizedStringResource, selection: Binding<TimeInterval>) -> some View {
        Picker(titleKey, selection: selection) {
            ForEach([TimeInterval]([5, 7, 10, 15, 30, 45, 60, 75, 90]), id: \.self) { interval in
                Text("\(Int(interval)) seconds")
                    .tag(interval)
            }
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
                Text("Type")
                Text("Updating this setting will exit the application.")
                    .font(.footnote)
            }
            LabeledContent("Identifier", value: receiver.identifier)
        } header: {
            Text("Receiver")
        }
    }

    private func debuggingSection() -> some View {
        Section {
            Button(action: simulateMemoryWarning) {
                Text("Simulate memory warning")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } header: {
            Text("Debugging")
        }
    }

    private func linksSection() -> some View {
        Section("Links") {
            Button("Website") { UIApplication.shared.open(.website) }
            Button("Source code") { UIApplication.shared.open(.castor) }
            Button("GitHub project") { UIApplication.shared.open(.project) }
                .swipeActions {
                    Button("Documentation") { UIApplication.shared.open(.documentation) }
                        .tint(.purple)
                }
            Button("Swift Package Index") { UIApplication.shared.open(.swiftPackageIndex) }
            Button("Pillarbox (Player SDK)") { UIApplication.shared.open(.pillarbox) }
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
                .foregroundStyle(.red)
                .pulseSymbolEffect17()
            Text(" in Switzerland")
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement()
        .accessibilityLabel("Made with love in Switzerland")
    }

    private func simulateMemoryWarning() {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }
}

private extension SettingsView {
    static func testFlightUrl(forApplicationIdentifier applicationIdentifier: String) -> URL? {
        let url = URL(string: "itms-beta://beta.itunes.apple.com/v1/app/")!.appending(path: applicationIdentifier)
        if UIApplication.shared.canOpenURL(url) {
            return url
        }
        else {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            components.scheme = "https"
            return components.url
        }
    }

    func openTestFlight(forApplicationIdentifier applicationIdentifier: String?) {
        guard let applicationIdentifier, let url = Self.testFlightUrl(forApplicationIdentifier: applicationIdentifier) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

private extension SettingsView {
    private func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
