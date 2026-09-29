//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

struct ChapterList: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    private var chapters: [PillarboxPlayer::Chapter] {
        player.metadata.chapters
    }

    private var currentChapter: PillarboxPlayer::Chapter? {
        chapters.first { $0.timeRange.containsTime(progressTracker.time) }
    }

    private var currentChapterTimeRange: Binding<CMTimeRange?> {
        .init {
            currentChapter?.timeRange
        } set: { [weak player] timeRange in
            guard let chapter = chapters.first(where: { $0.timeRange == timeRange }) else { return }
            player?.seek(to: chapter)
        }
    }

    var body: some View {
        List(chapters, id: \.timeRange, selection: currentChapterTimeRange) { chapter in
            HStack(spacing: 10) {
                artworkView(for: chapter)
                Text(chapter.title ?? "-")
            }
        }
        .bind(progressTracker, to: player)
    }

    private func artworkView(for chapter: PillarboxPlayer::Chapter) -> some View {
        Rectangle()
            .foregroundStyle(.quaternary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(height: 32)
            .overlay {
                LazyImage(source: chapter.imageSource) { image in
                    image
                        .resizable()
                        .scaledToFit()
                }
            }
    }
}
