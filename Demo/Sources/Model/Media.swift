//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation
import PillarboxCoreBusiness
import PillarboxPlayer

struct Media: Hashable, Identifiable {
    enum `Type`: Hashable {
        case deepLink(String)
        case urn(String)
        case url(URL, configuration: CastAssetURLConfiguration)

        static func url(_ url: URL) -> Self {
            .url(url, configuration: .init())
        }

        static func == (lhs: Media.`Type`, rhs: Media.`Type`) -> Bool {
            switch (lhs, rhs) {
            case let (.deepLink(lhsLink), .deepLink(rhsLink)):
                return lhsLink == rhsLink
            case let (.urn(lhsUrn), .urn(rhsUrn)):
                return lhsUrn == rhsUrn
            case let (.url(lhsUrl, configuration: _), .url(rhsUrl, configuration: _)):
                return lhsUrl == rhsUrl
            default:
                return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case let .deepLink(link):
                hasher.combine(link)
            case let .urn(urn):
                hasher.combine(urn)
            case let .url(url, configuration: _):
                hasher.combine(url)
            }
        }
    }

    let id = UUID()
    let title: String
    let imageUrl: URL?
    let type: Type

    init(title: String, imageUrl: URL? = nil, type: Type) {
        self.title = title
        self.imageUrl = imageUrl
        self.type = type
    }

    init(from asset: CastAsset) {
        let title = asset.metadata?.title ?? "Untitled"
        let imageUrl = asset.metadata?.imageUrl()
        switch asset.kind {
        case let .entity(entity):
            self.init(title: title, imageUrl: imageUrl, type: .deepLink(entity))
        case let .identifier(identifier):
            self.init(title: title, imageUrl: imageUrl, type: .urn(identifier))
        case let .url(url, configuration: configuration):
            self.init(title: title, imageUrl: imageUrl, type: .url(url, configuration: configuration))
        }
    }

    func item() -> PlayerItem {
        switch type {
        case let .deepLink(link):
            return .urn(URL(string: link)?.lastPathComponent ?? "urn:unknown")
        case let .urn(urn):
            return .urn(urn)
        case let .url(url, configuration: _):
            return .simple(url: url, metadata: self)
        }
    }

    func asset() -> CastAsset {
        switch type {
        case let .deepLink(link):
            return .entity(link, metadata: castMetadata())
        case let .urn(urn):
            return .identifier(urn, metadata: castMetadata())
        case let .url(url, configuration: configuration):
            return .url(url, configuration: configuration, metadata: castMetadata())
        }
    }

    func castMetadata() -> CastMetadata {
        .init(title: title, image: castImage())
    }

    private func castImage() -> CastImage? {
        guard let imageUrl else { return nil }
        return .init(url: imageUrl)
    }
}

extension Media: AssetMetadata {
    private var imageSource: ImageSource {
        guard let imageUrl else { return .none }
        return .url(standardResolution: imageUrl)
    }

    var playerMetadata: PlayerMetadata {
        .init(title: title, imageSource: imageSource)
    }
}

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
        title: "19h30 (FMP4)",
        imageUrl: "https://il.srgssr.ch/images/?imageUrl=https%3A%2F%2Fimg.rts.ch%2Fmedias%2F2025%2Fimage%2Frwhwbf-28972611.image&format=webp&width=1920",
        type: .url(
            "https://rts-vod-amd.akamaized.net/ww/db6241ed-2be5-326f-a85e-40e1742950ca/b94ab623-6e55-387c-8743-9c8cfb59de59/master.m3u8",
            configuration: .init(hlsVideoSegmentFormat: .FMP4)
        )
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
        type: .url("https://stream.srg-ssr.ch/m/couleur3/mp3_128")
    ),
    .init(
        title: "Radio Chablais",
        imageUrl: "https://alpsoft.ch/wp-content/uploads/2021/10/feat-radio-chablais-1080x675.jpg",
        type: .url("https://radiochablais.ice.infomaniak.ch/radiochablais-high.mp3")
    ),
    .init(
        title: "Skyrock",
        imageUrl: "https://www.radio.net/300/skyrock.png",
        type: .url("https://icecast.skyrock.net/s/natio_mp3_128k")
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
        type: .urn("urn:rts:video:14827306")
    ),
    .init(
        title: "SRF 1",
        type: .urn("urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    ),
    .init(
        title: "RTS 1",
        type: .urn("urn:rts:video:3608506")
    ),
    .init(
        title: "Puls - Gehirnerschütterung, Akutgeriatrie, Erlenpollen im Winter",
        type: .urn("urn:srf:video:40ca0277-0e53-4312-83e2-4710354ff53e")
    ),
    .init(
        title: "Bonjour la Suisse (5/5) - Que du bonheur?",
        type: .urn("urn:rts:video:8806923")
    )
]

let kDeepLinkMedias: [Media] = [
    .init(
        title: "Horizontal video",
        type: .deepLink("https://pillarbox.ch/play/urn:rts:video:14827306")
    ),
    .init(
        title: "SRF 1",
        type: .deepLink("https://pillarbox.ch/play/urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    ),
    .init(
        title: "RTS 1",
        type: .deepLink("https://pillarbox.ch/play/urn:rts:video:3608506")
    ),
    .init(
        title: "Puls - Gehirnerschütterung, Akutgeriatrie, Erlenpollen im Winter",
        type: .deepLink("https://pillarbox.ch/play/urn:srf:video:40ca0277-0e53-4312-83e2-4710354ff53e")
    ),
    .init(
        title: "Bonjour la Suisse (5/5) - Que du bonheur?",
        type: .deepLink("https://pillarbox.ch/play/urn:rts:video:8806923")
    )
]

private let kAppleImageUrl = URL(
    string: "https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200"
)!
