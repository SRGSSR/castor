//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use `SwiftUI.ContentUnavailableView`")
private struct ContentUnavailableViewIOS16: View {
    let title: String
    let systemImage: String
    let description: Text?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.secondary)
                .frame(height: 40)
            infoView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    init(_ title: String, systemImage: String, description: Text?) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }

    private func infoView() -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            if let description {
                description
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct UnavailableView: View {
    let title: String
    let systemImage: String
    let description: Text?

    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(title, systemImage: systemImage, description: description)
        } else {
            ContentUnavailableViewIOS16(title, systemImage: systemImage, description: description)
        }
    }

    init(_ title: String, systemImage: String, description: Text? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }
}

#Preview("iOS 16.0") {
    ContentUnavailableViewIOS16("title", systemImage: "circle.fill", description: Text(verbatim: "description"))
}

@available(iOS 17, *)
#Preview("iOS 17.0+") {
    ContentUnavailableView("title", systemImage: "circle.fill", description: Text(verbatim: "description"))
}
