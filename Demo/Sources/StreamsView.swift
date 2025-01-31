//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import SwiftUI

struct StreamsView: View {
    private let streams: [Stream] = [
        .init(
            title: "Apple Basic 4:3",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!
        ),
        .init(
            title: "Apple Basic 16:9",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        ),
        .init(
            title: "Apple Advanced 16:9 (TS)",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
        )
    ]

    @State private var selectedStream: Stream?

    var body: some View {
        List(streams, id: \.self) { stream in
            Button {
                if GoogleCast.isActive {
                    GoogleCast.load(url: stream.url)
                }
                else {
                    selectedStream = stream
                }
            } label: {
                Text(stream.title)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
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
