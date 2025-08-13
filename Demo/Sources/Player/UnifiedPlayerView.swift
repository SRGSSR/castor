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

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    private var isUserInterfaceEffectivelyHidden: Bool {
        isUserInterfaceHidden && cast.player == nil
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
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView { option, medias in
                    if let remotePlayer = cast.player {
                        remotePlayer.add(option, medias: medias)
                    }
                    else {
                        model.add(option, medias: medias)
                    }
                }
            }
        }
        .onAppear {
            guard let media else { return }
            if let remotePlayer = cast.player {
                remotePlayer.loadItem(from: media.asset())
            }
            else {
                model.entries = [.init(media: media)]
                model.play()
            }
        }
        .makeCastable(model, with: cast)
    }

    private func topBar() -> some View {
        HStack(spacing: 20) {
            closeButton()
            Spacer()
            addButton()
            CastButton(cast: cast)
        }
        .font(.system(size: 22))
        .foregroundColor(.white)
        .opacity(isUserInterfaceEffectivelyHidden ? 0 : 1)
        .animation(.default, value: isUserInterfaceEffectivelyHidden)
        .padding()
        .preventsTouchPropagation()
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
            Image(systemName: "xmark")
        }
    }
}

#Preview {
    UnifiedPlayerView(media: .init(title: "19h30", type: .urn("urn:rts:video:14827306")))
        .environmentObject(Cast())
}
