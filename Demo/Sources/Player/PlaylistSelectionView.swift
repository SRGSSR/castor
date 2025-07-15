//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct PlaylistSelectionView: View {
    let player: CastPlayer?

    @State private var selectedMedias: Set<Media> = []
    @State private var selectedInsertionOption: InsertionOption = .append
    @State private var multiplier = 1

    @Environment(\.dismiss) private var dismiss

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
                Button("Cancel", action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: add)
                    .disabled(selectedMedias.isEmpty)
            }
        }
    }

    private func picker() -> some View {
        Picker(selection: $selectedInsertionOption) {
            ForEach(InsertionOption.allCases, id: \.self) { option in
                Text(option.name)
                    .tag(option)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func list() -> some View {
        List(selection: $selectedMedias) {
            section("HLS streams", medias: kHlsUrlMedias)
            section("MP3 streams ", medias: kMP3UrlMedias)
            section("DASH streams", medias: kDashUrlMedias)
            if UserDefaults.standard.receiver.isSupportingUrns {
                section("URN-based streams", medias: kUrnMedias)
            }
        }
    }

    private func section(_ titleKey: LocalizedStringKey, medias: [Media]) -> some View {
        Section(titleKey) {
            ForEach(medias) { media in
                Text(media.title)
                    .tag(media)
            }
        }
    }

    private func stepper() -> some View {
        Stepper(value: $multiplier, in: 1...100) {
            LabeledContent("Multiplier", value: "×\(multiplier)")
        }
        .padding()
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        defer {
            dismiss()
        }
        guard let player else { return }
        let assets = Array(repeating: selectedMedias, count: multiplier).flatMap(\.self).map { $0.asset() }
        switch selectedInsertionOption {
        case .prepend:
            player.prependItems(from: assets)
        case .insertBefore:
            player.insertItems(from: assets, before: player.currentItem)
        case .insertAfter:
            player.insertItems(from: assets, after: player.currentItem)
        case .append:
            player.appendItems(from: assets)
        }
    }
}

private extension PlaylistSelectionView {
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
}
