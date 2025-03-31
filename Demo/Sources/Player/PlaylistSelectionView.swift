//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct PlaylistSelectionView: View {
    let queue: CastQueue

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
