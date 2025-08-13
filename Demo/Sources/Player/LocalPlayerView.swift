//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct LocalPlayerView: View {
    let media: Media

    @EnvironmentObject private var cast: Cast
    @StateObject private var model = PlayerViewModel()
    @State private var isUserInterfaceHidden = false

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        LocalPlaybackView(model: model, player: model.player, isUserInterfaceHidden: $isUserInterfaceHidden)
            .overlay(alignment: .top, content: topBar)
            .sheet(isPresented: $isSelectionPresented) {
                NavigationStack {
                    PlaylistSelectionView { option, medias in
                        model.add(option, medias: medias)
                    }
                }
            }
            .onAppear {
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
        .opacity(isUserInterfaceHidden ? 0 : 1)
        .animation(.default, value: isUserInterfaceHidden)
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
    LocalPlayerView(media: .init(title: "19h30", type: .urn("urn:rts:video:14827306")))
        .environmentObject(Cast())
}
