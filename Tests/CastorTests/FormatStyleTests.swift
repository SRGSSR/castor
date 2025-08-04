//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Castor
import Testing

struct FormatStyleTests {
    @Test
    func player_time_short_format_style() async throws {
        let shortFormatter = PlayerTimeShortFormatStyle()
        #expect(shortFormatter.format(.init(value: 1, timescale: 0)).isEmpty)
        #expect(shortFormatter.format(.init(value: 1, timescale: 1)) == "00:01")
        #expect(shortFormatter.format(.init(value: 60, timescale: 1)) == "01:00")
        #expect(shortFormatter.format(.init(value: 3600, timescale: 1)) == "60:00")
    }

    @Test
    func player_time_long_format_style() async throws {
        let shortFormatter = PlayerTimeLongFormatStyle()
        #expect(shortFormatter.format(.init(value: 1, timescale: 0)).isEmpty)
        #expect(shortFormatter.format(.init(value: 1, timescale: 1)) == "00:00:01")
        #expect(shortFormatter.format(.init(value: 60, timescale: 1)) == "00:01:00")
        #expect(shortFormatter.format(.init(value: 3600, timescale: 1)) == "01:00:00")
    }
}
