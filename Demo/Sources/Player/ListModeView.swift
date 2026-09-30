//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ListModeView: View {
    @Binding var listMode: ListMode

    var body: some View {
        Picker(selection: $listMode) {
            ForEach(ListMode.allCases, id: \.self) { selection in
                Text(selection.name).tag(selection)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
