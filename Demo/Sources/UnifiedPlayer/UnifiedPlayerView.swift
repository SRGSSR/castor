//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

struct UnifiedPlayerView: View {
    @EnvironmentObject private var cast: Cast
    @StateObject private var viewModel = UnifiedPlayerViewModel(playerContent: .init(medias: kUrnMedias)!)

    var body: some View {
        Group {
            if let remotePlayer = cast.player {
                UnifiedPlayerRemoteView(player: remotePlayer)
            }
            else {
                UnifiedPlayerLocalView(player: viewModel.localPlayer, viewModel: viewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CastButton(cast: cast)
            }
        }
        .supportsCast(cast, with: viewModel)
        .makeCastable(viewModel, with: cast)
        .onChange(of: cast.player) { remotePlayer in
            viewModel.bind(remotePlayer: remotePlayer)
        }
        .onAppear {
            viewModel.bind(remotePlayer: cast.player)
            initialPlayersLoading()
        }
    }

    func initialPlayersLoading() {
        if let remotePlayer = cast.player {
            if remotePlayer.items.isEmpty {
                remotePlayer.loadItems(from: viewModel.medias.map { $0.asset() })
                remotePlayer.play()
            }
        }
        else if viewModel.localPlayer.items.isEmpty {
            let content = PlayerContent(medias: viewModel.medias)
            viewModel.localPlayer.items = content?.items() ?? []
            viewModel.localPlayer.play()
        }
    }
}

#Preview {
    RootView()
}
