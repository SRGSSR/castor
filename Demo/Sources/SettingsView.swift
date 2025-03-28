//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.DemoSettingKey.receiver)
    private var receiver: Receiver = .standard

    var body: some View {
        Form {
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
            } footer: {
                versionFooter()
            }
        }
        .onChange(of: receiver) { _, _ in exit(0) }
        .navigationTitle("Settings")
    }

    private func versionFooter() -> some View {
        HStack(spacing: 0) {
            Text("Made with ")
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .symbolEffect(.pulse)
            Text(" in Switzerland")
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement()
        .accessibilityLabel("Made with love in Switzerland")
    }
}

#Preview {
    SettingsView()
}
