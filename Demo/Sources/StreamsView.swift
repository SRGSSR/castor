//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct StreamsView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.bubble")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64)
            Text("Demo app under development for the Castor SDK (https://github.com/SRGSSR/castor) distributed via SPM, based on Google Cast")
                .font(.headline)
                .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .navigationTitle("Castor")
    }
}

#Preview {
    NavigationStack {
        StreamsView()
    }
}
