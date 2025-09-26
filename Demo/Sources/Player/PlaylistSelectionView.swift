//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct PlaylistSelectionView: View {
    let completion: (InsertionOption, [Media]) -> Void

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
            section("HLS URLs", medias: kHlsUrlMedias)
            section("MP3 URLs ", medias: kMP3UrlMedias)
            section("DASH URLs", medias: kDashUrlMedias)
            if UserDefaults.standard.receiver.isSrgSsrReceiver {
                section("URNs", medias: kUrnMedias)
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
        completion(selectedInsertionOption, Array(repeating: selectedMedias, count: multiplier).flatMap(\.self))
    }
}

extension PlaylistSelectionView {
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

extension PlayerViewModel {
    func apply(_ option: PlaylistSelectionView.InsertionOption, with medias: [Media]) {
        let entries = medias.map { PlaylistEntry(media: $0) }
        switch option {
        case .prepend:
            prependItems(from: entries)
        case .insertBefore:
            insertItemsBeforeCurrent(from: entries)
        case .insertAfter:
            insertItemsAfterCurrent(from: entries)
        case .append:
            appendItems(from: entries)
        }
    }
}

extension CastPlayer {
    func apply(_ option: PlaylistSelectionView.InsertionOption, with medias: [Media]) {
        let assets = medias.map { $0.asset() }
        switch option {
        case .prepend:
            prependItems(from: assets)
        case .insertBefore:
            insertItems(from: assets, before: currentItem)
        case .insertAfter:
            insertItems(from: assets, after: currentItem)
        case .append:
            appendItems(from: assets)
        }
    }
}
