//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import SwiftUI

struct StreamsView: View {
    private static let kAppleImageUrl = URL(string: "https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200")!
    private let streams: [Stream] = [
        .init(
            title: "Apple Basic 4:3",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!,
            imageUrl: kAppleImageUrl
        ),
        .init(
            title: "Apple Basic 16:9",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
            imageUrl: kAppleImageUrl
        ),
        .init(
            title: "Apple Advanced 16:9 (TS)",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
            imageUrl: kAppleImageUrl
        )
    ]

    @State private var selectedStream: Stream?
    @StateObject private var googleCast = GoogleCast()

    var body: some View {
        VStack(spacing: 0) {
            List(streams) { stream in
                Button {
                    if googleCast.isActive {
                        GoogleCast.load(stream: stream)
                    }
                    else {
                        selectedStream = stream
                    }
                } label: {
                    Text(stream.title)
                }
            }
            if googleCast.isLoaded {
                MiniMediaControlsView()
                    .frame(height: 64)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.linear(duration: 0.2), value: googleCast.isLoaded)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CastButton()
            }
        }
        .sheet(item: $selectedStream) { stream in
            PlayerView(url: stream.url)
        }
        .navigationTitle("Castor")
    }
}

#Preview {
    NavigationStack {
        StreamsView()
    }
}
