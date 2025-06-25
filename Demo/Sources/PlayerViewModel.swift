//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import SwiftUI

class PlayerViewModel {
    let player = AVPlayer()

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
}
