//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import SwiftUI

class PlayerViewModel: CastDelegate {
    let player = AVPlayer()
    var cast: Cast? {
        didSet {
            cast?.delegate = self
        }
    }

    var dismiss: DismissAction?

    var media: Media? {
        didSet {
            guard media != oldValue else { return }
            switch media?.type {
            case let .url(url):
                player.replaceCurrentItem(with: .init(url: url))
            default:
                player.replaceCurrentItem(with: nil)
            }
        }
    }

    func play() {
        player.play()
    }

    func cast(_ cast: Cast, didStartSessionWithPlayer player: CastPlayer) {
        if let url = (self.player.currentItem?.asset as? AVURLAsset)?.url, let media {
            player.loadItem(from: .simple(url: url, metadata: .init(title: media.title, image: .init(url: media.imageUrl))))
            dismiss?()
        }
    }

    func cast(_ cast: Cast, willStopSessionWithPlayer player: CastPlayer) {
    }
}
