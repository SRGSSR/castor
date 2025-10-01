//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Testing

@testable import Castor

@Suite
struct CastResumeStateTests {
    @Test
    func empty() throws {
        #expect(CastResumeState(assets: [], options: .init(index: 0, time: .invalid)) == nil)
    }

    @Test
    func filled() throws {
        let state = try #require(
            CastResumeState(
                assets: [
                    .url(URL(string: "https://localhost/stream.m3u8")!, metadata: nil)
                ],
                options: .init(index: 0, time: .zero)
            )
        )
        #expect(state.assets.count == 1)
    }

    @Test
    func input_check() {
        #expect(
            CastResumeState(
                assets: [
                    .url(URL(string: "https://localhost/stream.m3u8")!, metadata: nil)
                ],
                options: .init(index: 1, time: .zero)
            ) == nil
        )
    }

    @Test
    func media_selection() throws {
        var state = try #require(
            CastResumeState(
                assets: [
                    .url(URL(string: "https://localhost/stream.m3u8")!, metadata: nil)
                ],
                options: .init(index: 0, time: .zero)
            )
        )
        state.setMediaSelection(language: "fr", for: .legible)
        #expect(state.mediaSelectionLanguage(for: .legible) == "fr")
    }
}
