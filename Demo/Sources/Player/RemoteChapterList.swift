//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import PillarboxPlayer
import SwiftUI

struct RemoteChapterList: View {
    @ObservedObject var player: CastPlayer
    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 10))

    private var currentChapter: Chapter? {
        player.chapters.first { $0.timeRange.containsTime(progressTracker.time) }
    }

    private var currentChapterTimeRange: Binding<CMTimeRange?> {
        .init {
            currentChapter?.timeRange
        } set: { [weak player] timeRange in
            guard let chapter = player!.chapters.first(where: { $0.timeRange == timeRange }) else { return }
            player?.seek(to: chapter.timeRange.start)
        }
    }

    var body: some View {
        List(player.chapters, id: \.timeRange, selection: currentChapterTimeRange) { chapter in
            HStack(spacing: 10) {
                artworkView(for: chapter)
                Text(chapter.title)
            }
        }
        .bind(progressTracker, to: player)
    }

    private func artworkView(for chapter: Chapter) -> some View {
        Rectangle()
            .foregroundStyle(.quaternary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(height: 32)
            .overlay {
                AsyncImage(url: chapter.posterUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    EmptyView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
    }
}
