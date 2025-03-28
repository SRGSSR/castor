//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import GoogleCast
import SwiftUI

private struct MainView: View {
    private static let shortFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let longFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    var body: some View {
        VStack {
            currentItemView()
            playlist()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var imageName: String {
        player.state == .playing ? "pause.fill" : "play.fill"
    }

    private var title: String? {
        player.mediaInformation?.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    private var imageUrl: URL? {
        guard let image = player.mediaInformation?.metadata?.images().first as? GCKImage else { return nil }
        return image.url
    }

    private var progress: Float? {
        let time = player.time()
        let timeRange = player.seekableTimeRange()
        guard time.isValid, timeRange.isValid, !timeRange.isEmpty else { return nil }
        return Float(time.seconds / timeRange.duration.seconds).clamped(to: 0...1)
    }

    private static func formattedTime(_ time: CMTime, duration: CMTime) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatter.string(from: time.seconds)!
        }
        else {
            return longFormatter.string(from: time.seconds)!
        }
    }

    private func artworkImage() -> some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
        } placeholder: {
            Image(systemName: "photo")
                .resizable()
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 160)
    }

    private func loadingIndicator() -> some View {
        ProgressView()
            .tint(.white)
            .padding(10)
            .background(
                Circle()
                    .fill(Color(white: 0, opacity: 0.4))
            )
            .opacity(player.isBusy ? 1 : 0)
            .animation(.default, value: player.isBusy)
    }

    @ViewBuilder
    private func progressView() -> some View {
        HStack {
            if let elapsedTime = Self.formattedTime(player.time(), duration: player.seekableTimeRange().duration) {
                Text(elapsedTime)
            }
            if let progress {
                ProgressView(value: progress)
            }
            if let totalTime = Self.formattedTime(player.seekableTimeRange().duration, duration: player.seekableTimeRange().duration) {
                Text(totalTime)
            }
        }
        .frame(height: 30)
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func stopButton() -> some View {
        Button(action: player.stop) {
            Image(systemName: "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func buttons() -> some View {
        HStack(spacing: 40) {
            playbackButton()
            stopButton()
        }
        .frame(height: 60)
    }

    private func informationView() -> some View {
        VStack {
            if let title {
                Text(title)
            }
            if let device {
                Text("Connected to \(device.name ?? "receiver")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func visualView() -> some View {
        ZStack {
            artworkImage()
            loadingIndicator()
        }
        .padding()
    }

    private func controls() -> some View {
        VStack {
            progressView()
            buttons()
        }
        .padding()
    }

    private func currentItemView() -> some View {
        VStack {
            informationView()
            visualView()
            controls()
        }
    }

    private func playlist() -> some View {
        CastQueueView(queue: player.queue)
    }
}

private struct CastQueueView: View {
    @ObservedObject var queue: CastQueue
    @State private var isSelectionPresented = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar()
            list()
        }
    }

    private func list() -> some View {
        ZStack {
            if !queue.items.isEmpty {
                List($queue.items, id: \.self, editActions: .all, selection: queue.currentItemSelection) { $item in
                    CastQueueCell(item: item)
                }
            }
            else {
                ContentUnavailableView {
                    Text("No items")
                }
            }
        }
        .animation(.linear, value: queue.items)
    }

    private func toolbar() -> some View {
        HStack {
            previousButton()
            Spacer()
            managementButtons()
            Spacer()
            nextButton()
        }
        .padding()
    }

    private func previousButton() -> some View {
        Button(action: queue.returnToPreviousItem) {
            Image(systemName: "arrow.left")
        }
        .disabled(!queue.canReturnToPreviousItem())
    }

    private func managementButtons() -> some View {
        HStack(spacing: 30) {
            Button(action: shuffle) {
                Image(systemName: "shuffle")
            }
            .disabled(queue.isEmpty)

            Button {
                isSelectionPresented.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $isSelectionPresented) {
                NavigationStack {
                    PlaylistSelectionView(queue: queue)
                }
            }

            Button(action: queue.removeAllItems) {
                Image(systemName: "trash")
            }
            .disabled(queue.isEmpty)
        }
        .padding()
    }

    private func nextButton() -> some View {
        Button(action: queue.advanceToNextItem) {
            Image(systemName: "arrow.right")
        }
        .disabled(!queue.canAdvanceToNextItem())
    }

    private func shuffle() {
        queue.items.shuffle()
    }
}

private struct PlaylistSelectionView: View {
    enum InsertionOption: CaseIterable {
        case prepend
        case insertBefore
        case insertAfter
        case append

        var name: LocalizedStringKey {
            switch self {
            case .prepend:
                "Prepend"
            case .insertBefore:
                "Insert before"
            case .insertAfter:
                "Insert after"
            case .append:
                "Append"
            }
        }
    }

    let queue: CastQueue
    @State private var selectedMedias: Set<Media> = []
    @Environment(\.dismiss) private var dismiss
    @State private var selectedInsertionOption: InsertionOption = .append
    @State private var multiplier = 1

    var body: some View {
        VStack {
            picker()
            list()
            stepper()
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Add content")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: add)
                    .disabled(selectedMedias.isEmpty)
            }
        }
    }

    private func picker() -> some View {
        Picker("Insertion options", selection: $selectedInsertionOption) {
            ForEach(InsertionOption.allCases, id: \.self) { option in
                Text(option.name)
                    .tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func list() -> some View {
        List(kMedias, id: \.self, selection: $selectedMedias) { media in
            Text(media.title)
        }
    }

    private func stepper() -> some View {
        Stepper(value: $multiplier, in: 1...100) {
            LabeledContent("Multiplier", value: "×\(multiplier)")
        }
        .padding()
    }

    private func add() {
        let assets = Array(repeating: selectedMedias.map { $0.asset() }, count: multiplier).flatMap(\.self)
        switch selectedInsertionOption {
        case .prepend:
            queue.prependItems(from: assets)
        case .insertBefore:
            queue.insertItems(from: assets, before: queue.currentItem)
        case .insertAfter:
            queue.insertItems(from: assets, after: queue.currentItem)
        case .append:
            queue.appendItems(from: assets)
        }
        dismiss()
    }
}

private struct CastQueueCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            AsyncImage(url: item.metadata?.imageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 64, height: 64)

            Text(title)
                .onAppear(perform: item.fetch)
                .redactedIfNil(item.metadata)
        }
    }

    private var title: String {
        guard let metadata = item.metadata else { return .placeholder(length: .random(in: 20...30)) }
        return metadata.title ?? "-"
    }
}

struct CastPlayerView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        ZStack {
            if let player = cast.player {
                MainView(player: player, device: cast.currentDevice)
            }
            else {
                ContentUnavailableView("Not connected", systemImage: "wifi.slash")
                    .overlay(alignment: .topTrailing) {
                        ProgressView()
                            .padding()
                            .opacity(cast.connectionState == .connecting ? 1 : 0)
                    }
            }
        }
        .animation(.default, value: cast.player)
    }
}

#Preview {
    CastPlayerView()
        .environmentObject(Cast())
}
