//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import PillarboxPlayer
import SwiftUI

private struct LocalPlayerView: View {
    @ObservedObject var player: Player

    var body: some View {
        Text("Local player")
    }
}

private struct RemotePlayerView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Text("Remote player")
    }
}

struct PlayerView: View {
    @EnvironmentObject private var cast: Cast
    @StateObject private var player = Player()

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    @AppStorage(UserDefaults.DemoSettingKey.playerType)
    private var playerType: PlayerType = .standard

    var body: some View {
        NavigationStack {
            mainView()
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

    @ViewBuilder
    func mainView() -> some View {
        if let remotePlayer = cast.player {
            switch playerType {
            case .standard:
                CastPlayerView(cast: cast)
            case .custom:
                RemotePlayerView(player: remotePlayer)
            }
        }
        else {
            LocalPlayerView(player: player)
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
