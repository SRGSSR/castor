//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128)
            Text("CASTOR")
                .font(.title)
                .fontWeight(.black)
                .foregroundStyle(.accent)
        }
    }
}

#Preview {
    ContentView()
}
