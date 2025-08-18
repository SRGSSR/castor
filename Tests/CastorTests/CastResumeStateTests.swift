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
        #expect(CastResumeState(assets: [], index: nil, time: .invalid) == nil)
    }

    @Test
    func filled() throws {
        let state = try #require(
            CastResumeState(
                assets: [
                    .url(URL(string: "https://localhost/stream.m3u8")!, metadata: nil)
                ],
                index: 0,
                time: .zero
            )
        )
        #expect(state.assets.count == 1)
        #expect(state.index == 0)
        #expect(state.time == .zero)
        #expect(state.mediaSelectionPreferredLanguages(for: .legible).isEmpty)
    }

    @Test
    func input_check() {
        #expect(
            CastResumeState(
                assets: [
                    .url(URL(string: "https://localhost/stream.m3u8")!, metadata: nil)
                ],
                index: 1,
                time: .zero
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
                index: 0,
                time: .zero
            )
        )
        state.setMediaSelection(preferredLanguages: ["en", "fr"], for: .legible)
        #expect(state.mediaSelectionPreferredLanguages(for: .legible) == ["en", "fr"])
    }
}
