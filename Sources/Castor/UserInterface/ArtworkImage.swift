//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ArtworkImage: View {
    let url: URL?

    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.2))
            .aspectRatio(contentMode: .fit)
            .overlay {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    ArtworkImage(url: URL(string: "https://img.rts.ch/articles/2025/image/ivl0kf-28939713.image?w=1280&h=720")!)
        .padding()
}
