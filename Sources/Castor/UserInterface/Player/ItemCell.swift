//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ItemCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            artworkImage()
            Text(title)
                .redacted(!item.isFetched)
            Spacer()
            disclosureImage()
        }
        .accessibilityElement()
        .accessibilityLabel(title)
        .onAppear(perform: item.fetch)
    }

    private var title: String {
        guard item.isFetched else { return .placeholder(length: .random(in: 20...30)) }
        return CastAsset.name(for: item.asset)
    }

    private func artworkImage() -> some View {
        ArtworkImage(url: item.asset?.metadata?.imageUrl(matching: .init(type: .custom, size: .init(width: 45, height: 45))))
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            .frame(height: 45)
    }

    private func disclosureImage() -> some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
    }
}
