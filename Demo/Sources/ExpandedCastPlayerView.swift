//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct ExpandedCastPlayerView: View {
    @ObservedObject var cast: Cast
    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                CastPlayerView(cast: cast)
                if let player = cast.player {
                    DRMView(player: player)
                }
            }
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
                PlaylistSelectionView(player: cast.player)
            }
        }
    }

    private func addButton() -> some View {
        Button {
            isSelectionPresented.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }

    private func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
        }
    }
}

struct DRMView: View {
    @ObservedObject var player: CastPlayer

    private var drmInfo: DRMInfo? {
        if let info = player.customData?.decoded(as: DRMInfo.self) {
            return info
        }
        else {
            return nil
        }
    }

    var body: some View {
        VStack {
            LabeledContent("License", value: drmInfo?.licenseUrl ?? "-")
            LabeledContent("Certif", value: drmInfo?.certificateUrl ?? "-")
        }
    }
}
