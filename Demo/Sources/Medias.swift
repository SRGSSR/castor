//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

let kMedias = UserDefaults.standard.receiver == .srgssr ? (kUrlMedias + kUrnMedias) : kUrlMedias

private let kAppleImageUrl = URL(
    string: "https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200"
)!

private let kUrlMedias: [Media] = [
    .init(
        title: "Apple Basic 4:3",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
    ),
    .init(
        title: "Apple Basic 16:9",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")
    ),
    .init(
        title: "Apple Advanced 16:9 (TS)",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")
    ),
    .init(
        title: "Swiss wheelchair athlete wins top award",
        imageUrl: "https://cdn.prod.swi-services.ch/video-delivery/images/94f5f5d1-5d53-4336-afda-9198462c45d9/_.1hAGinujJ.yERGrrGNzBGCNSxmhKZT/16x9",
        type: .url("https://cdn.prod.swi-services.ch/video-projects/94f5f5d1-5d53-4336-afda-9198462c45d9/localised-videos/ENG/renditions/ENG.mp4")
    ),
    .init(
        title: "Couleur 3",
        imageUrl: "https://img.rts.ch/audio/2010/image/924h3y-25865853.image?w=640&h=640",
        type: .url("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    ),
    .init(
        title: "Tagesschau",
        imageUrl: "https://images.tagesschau.de/image/89045d82-5cd5-46ad-8f91-73911add30ee/AAABh3YLLz0/AAABibBx2rU/20x9-1280/tagesschau-logo-100.jpg",
        type: .url("https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")
    )
]

private let kUrnMedias: [Media] = [
    .init(
        title: "Horizontal video",
        imageUrl: "https://www.rts.ch/2024/04/10/19/23/14827621.image/16x9",
        type: .urn("urn:rts:video:14827306")
    ),
    .init(
        title: "SRF 1",
        imageUrl: "https://ws.srf.ch/asset/image/audio/d91bbe14-55dd-458c-bc88-963462972687/EPISODE_IMAGE",
        type: .urn("urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    ),
    .init(
        title: "RTS 1",
        imageUrl: "https://www.rts.ch/2023/09/06/14/43/14253742.image/16x9",
        type: .urn("urn:rts:video:3608506")
    ),
    .init(
        title: "Puls - Gehirnerschütterung, Akutgeriatrie, Erlenpollen im Winter",
        imageUrl: "https://ws.srf.ch/asset/image/audio/3bc7c819-9f77-4b2f-bbb1-6787df21d7bc/WEBVISUAL/1641807822.jpg",
        type: .urn("urn:srf:video:40ca0277-0e53-4312-83e2-4710354ff53e")
    )
]
