//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.DemoSettingKey.receiver.rawValue)
    private var receiver: Receiver = .standard

    @State private var animate = false

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
            }
        }
        .onChange(of: receiver) { _, _ in exit(0) }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
