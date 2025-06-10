//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol MutableSynchronizerRecipe: BaseSynchronizerRecipe {
    init(service: Service, update: @escaping (Status?) -> Void, completion: @escaping (Bool) -> Void)

    func makeRequest(for value: Value) -> Bool
}
