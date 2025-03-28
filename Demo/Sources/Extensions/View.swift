//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

extension View {
    func redactedIfNil(_ object: Any?) -> some View {
        redacted(reason: object == nil ? .placeholder : .init())
    }
}
