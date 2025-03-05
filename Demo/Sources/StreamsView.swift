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
        ),
        .init(
            title: "Swiss wheelchair athlete wins top award",
            url: URL(string: "https://cdn.prod.swi-services.ch/video-projects/94f5f5d1-5d53-4336-afda-9198462c45d9/localised-videos/ENG/renditions/ENG.mp4")!,
            // swiftlint:disable:next line_length
            imageUrl: URL(string: "https://cdn.prod.swi-services.ch/video-delivery/images/94f5f5d1-5d53-4336-afda-9198462c45d9/_.1hAGinujJ.yERGrrGNzBGCNSxmhKZT/16x9")!
        ),
        .init(
            title: "Couleur 3",
            url: URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!,
            imageUrl: URL(string: "https://img.rts.ch/audio/2010/image/924h3y-25865853.image?w=640&h=640")!
        ),
        .init(
            title: "Tagesschau",
            url: URL(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!,
            // swiftlint:disable:next line_length
            imageUrl: URL(string: "https://images.tagesschau.de/image/89045d82-5cd5-46ad-8f91-73911add30ee/AAABh3YLLz0/AAABibBx2rU/20x9-1280/tagesschau-logo-100.jpg")!
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
            ToolbarItem(placement: .topBarLeading) {
                Button(action: batchLoad) {
                    Text("Load > 20")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: append) {
                    Text("Append")
                }
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

    private func batchLoad() {
        guard googleCast.isActive else { return }
        GoogleCast.load(streams: streams + streams + streams + streams)
    }

    private func append() {
        guard googleCast.isActive, let stream = streams.randomElement() else { return }
        GoogleCast.append(stream: stream)
    }
}

#Preview {
    NavigationStack {
        StreamsView()
    }
}
