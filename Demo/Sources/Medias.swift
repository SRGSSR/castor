//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

let kHlsUrlMedias: [Media] = [
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
        title: "Tagesschau",
        imageUrl: "https://images.tagesschau.de/image/89045d82-5cd5-46ad-8f91-73911add30ee/AAABh3YLLz0/AAABibBx2rU/20x9-1280/tagesschau-logo-100.jpg",
        type: .url("https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")
    )
]

let kMP3UrlMedias: [Media] = [
    .init(
        title: "Couleur 3",
        imageUrl: "https://img.rts.ch/audio/2010/image/924h3y-25865853.image?w=640&h=640",
        type: .url("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    ),
    .init(
        title: "Radio Chablais",
        imageUrl: "https://alpsoft.ch/wp-content/uploads/2021/10/feat-radio-chablais-1080x675.jpg",
        type: .url("https://radiochablais.ice.infomaniak.ch/radiochablais-high.mp3")
    ),
    .init(
        title: "Skyrock",
        imageUrl: "https://www.radio.net/300/skyrock.png",
        type: .url("http://icecast.skyrock.net/s/natio_mp3_128k")
    ),
    .init(
        title: "Country Radio Gilsdorf",
        imageUrl: "https://static.wixstatic.com/media/7b176c_f543664008a447f3b2adbb1d231b21e1~mv2.jpg",
        type: .url("http://streaming.aoip.international:8000/cr-gilsdorf")
    )
]

let kDashUrlMedias: [Media] = [
    .init(
        title: "VOD",
        imageUrl: "https://dashif.org/img/dashif-logo-283x100_new.jpg",
        type: .url("https://dash.akamaized.net/dash264/TestCases/1a/netflix/exMPD_BIP_TC1.mpd")
    ),
    .init(
        title: "Live",
        imageUrl: "https://website-storage.unified-streaming.com/images/_1200x630_crop_center-center_none/default-facebook.png",
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.mpd?time_shift=300")
    )
]

let kUrnMedias: [Media] = [
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
    ),
    .init(
        title: "Bonjour la Suisse (5/5) - Que du bonheur?",
        imageUrl: "https://www.rts.ch/2017/07/28/21/11/8806915.image/16x9",
        type: .urn("urn:rts:video:8806923")
    )
]

private let kAppleImageUrl = URL(
    string: "https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200"
)!
