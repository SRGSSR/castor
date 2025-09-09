//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import PillarboxPlayer
import SwiftUI

struct UnifiedPlayerView: View {
    let media: Media?

    @EnvironmentObject private var cast: Cast
    @State private var model = PlayerViewModel()
    @State private var isUserInterfaceHidden = false

    @State private var isPresentingDeviceSelection = false
    @State private var isPlaylistSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    private var isUserInterfaceActuallyHidden: Bool {
        !isPresentingDeviceSelection && isUserInterfaceHidden && cast.player == nil
    }

    var body: some View {
        ZStack {
            if let remotePlayer = cast.player {
                RemotePlaybackView(player: remotePlayer)
            }
            else {
                LocalPlaybackView(model: model, player: model.player, isUserInterfaceHidden: $isUserInterfaceHidden)
            }
        }
        .animation(.default, value: cast.player)
        .overlay(alignment: .top, content: topBar)
        .sheet(isPresented: $isPlaylistSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView { option, medias in
                    if let remotePlayer = cast.player {
                        remotePlayer.apply(option, with: medias)
                    }
                    else {
                        model.apply(option, with: medias)
                    }
                }
            }
        }
        .onAppear(perform: playMedia)
        .makeCastable(model, with: cast)
    }

    private func playMedia() {
        guard let media, cast.player == nil else { return }
        model.entries = [.init(media: media)]
        model.play()
    }
}

private extension UnifiedPlayerView {
    func topBar() -> some View {
        HStack(spacing: 20) {
            closeButton()
            Spacer()
            addButton()
            CastButton(cast: cast, isPresenting: $isPresentingDeviceSelection)
        }
        .font(.system(size: 22))
        .foregroundStyle(.white)
        .opacity(isUserInterfaceActuallyHidden ? 0 : 1)
        .animation(.default, value: isUserInterfaceActuallyHidden)
        .padding()
        .preventsTouchPropagation()
    }

    func addButton() -> some View {
        Button {
            isPlaylistSelectionPresented.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }

    func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
    }
}

#Preview {
    UnifiedPlayerView(media: .init(title: "19h30", type: .urn("urn:rts:video:14827306")))
        .environmentObject(Cast())
}
