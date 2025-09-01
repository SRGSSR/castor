//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@MainActor
extension Binding {
    init<T>(_ object: T, at keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
