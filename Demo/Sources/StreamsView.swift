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
        ),
        .init(
            title: "Apple Advanced 16:9 (fMP4)",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
        ),
        .init(
            title: "Apple Advanced 16:9 (HEVC/H.264)",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!
        ),
        .init(
            title: "Apple Dolby Atmos",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")!
        ),
        .init(
            title: "Apple WWDC Keynote 2023",
            url: URL(string: "https://events-delivery.apple.com/0105cftwpxxsfrpdwklppzjhjocakrsk/m3u8/vod_index-PQsoJoECcKHTYzphNkXohHsQWACugmET.m3u8")!
        ),
        .init(
            title: "The Morning Show - My Way: Season 1",
            // swiftlint:disable:next line_length
            url: URL(string: "https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1522121579&isExternal=true&brandId=tvs.sbd.4000&id=518077009&l=en-GB&aec=UHD")!
        ),
        .init(
            title: "The Morning Show - Change: Season 2",
            // swiftlint:disable:next line_length
            url: URL(string: "https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1568297173&isExternal=true&brandId=tvs.sbd.4000&id=518034010&l=en-GB&aec=UHD")!
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
