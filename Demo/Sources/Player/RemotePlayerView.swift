//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct RemotePlayerView: View {
    @EnvironmentObject private var cast: Cast

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            CastPlayerView(cast: cast)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        closeButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        addButton()
                    }
                }
                .toolbarBackground(.background, for: .navigationBar)
        }
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView { option, medias in
                    guard let remotePlayer = cast.player else { return }
                    remotePlayer.add(option, medias: medias)
                }
            }
        }
    }

    private func addButton() -> some View {
        Button {
            isSelectionPresented.toggle()
        } label: {
            Image(systemName: "plus")
        }
        .disabled(cast.player == nil)
    }

    private func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
        }
    }
}

#Preview {
    RemotePlayerView()
        .environmentObject(Cast())
}
