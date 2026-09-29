//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Chapter: Decodable {
    let identifier: String
    let title: String
    let posterUrl: URL
    let startTime: Double
    let endTime: Double
}
