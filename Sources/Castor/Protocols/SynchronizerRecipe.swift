//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol SynchronizerRecipe: BaseSynchronizerRecipe {
    init(service: Service, update: @escaping (Status?) -> Void)
}
