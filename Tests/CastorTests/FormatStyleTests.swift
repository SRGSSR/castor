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
        let formatter = PlayerTimeShortFormatStyle()
        #expect(formatter.format(.invalid).isEmpty)
        #expect(formatter.format(.zero) == "00:00")
        #expect(formatter.format(.init(value: 1, timescale: 1)) == "00:01")
        #expect(formatter.format(.init(value: 60, timescale: 1)) == "01:00")
        #expect(formatter.format(.init(value: 3600, timescale: 1)) == "60:00")
    }

    @Test
    func player_time_long_format_style() async throws {
        let formatter = PlayerTimeLongFormatStyle()
        #expect(formatter.format(.invalid).isEmpty)
        #expect(formatter.format(.zero) == "00:00:00")
        #expect(formatter.format(.init(value: 1, timescale: 1)) == "00:00:01")
        #expect(formatter.format(.init(value: 60, timescale: 1)) == "00:01:00")
        #expect(formatter.format(.init(value: 3600, timescale: 1)) == "01:00:00")
    }

    @Test
    func player_time_adaptive_format_style() async throws {
        var formatter = PlayerTimeAdaptiveFormatStyle(duration: 0)
        #expect(formatter.format(.invalid).isEmpty)
        #expect(formatter.format(.zero).isEmpty)
        #expect(formatter.format(.init(value: 1, timescale: 1)).isEmpty)

        formatter = PlayerTimeAdaptiveFormatStyle(duration: 3599)
        #expect(formatter.format(.invalid).isEmpty)
        #expect(formatter.format(.zero) == "00:00")
        #expect(formatter.format(.init(value: 1, timescale: 1)) == "00:01")
        #expect(formatter.format(.init(value: 60, timescale: 1)) == "01:00")
        #expect(formatter.format(.init(value: 3600, timescale: 1)) == "60:00")

        formatter = PlayerTimeAdaptiveFormatStyle(duration: 3600)
        #expect(formatter.format(.invalid).isEmpty)
        #expect(formatter.format(.zero) == "00:00:00")
        #expect(formatter.format(.init(value: 1, timescale: 1)) == "00:00:01")
        #expect(formatter.format(.init(value: 60, timescale: 1)) == "00:01:00")
        #expect(formatter.format(.init(value: 3600, timescale: 1)) == "01:00:00")
    }
}
