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

    @State private var isPresentingDeviceSelection = false
    @State private var isPlaylistSelectionPresented = false

    @Environment(\.dismiss) private var dismiss

    private var isUserInterfaceActuallyHidden: Bool {
        !isPresentingDeviceSelection && isUserInterfaceHidden
    }

    var body: some View {
        LocalPlaybackView(model: model, player: model.player, isUserInterfaceHidden: $isUserInterfaceHidden)
            .overlay(alignment: .top, content: topBar)
            .sheet(isPresented: $isPlaylistSelectionPresented) {
                NavigationStack {
                    PlaylistSelectionView { option, medias in
                        model.apply(option, with: medias)
                    }
                }
            }
            .onAppear(perform: load)
            .makeCastable(model, with: cast)
    }

    private func load() {
        if let remotePlayer = cast.player {
            remotePlayer.loadItem(from: media.asset())
        }
        else {
            model.entries = [.init(media: media)]
            model.play()
        }
    }
}

private extension LocalPlayerView {
    func topBar() -> some View {
        HStack(spacing: 20) {
            closeButton()
            Spacer()
            addButton()
            CastButton(cast: cast, isPresenting: $isPresentingDeviceSelection)
        }
        .font(.system(size: 22))
        .foregroundColor(.white)
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
    LocalPlayerView(media: .init(title: "19h30", type: .urn("urn:rts:video:14827306")))
        .environmentObject(Cast())
}
