//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol MutableSynchronizerRecipe: BaseSynchronizerRecipe {
    associatedtype Requester

    var requester: Requester? { get }

    init(service: Service, update: @escaping (Status?) -> Void, completion: @escaping (Bool) -> Void)

    func makeRequest(for value: Value, using requester: Requester)
}

extension MutableSynchronizerRecipe where Service == Requester {
    var requester: Requester? {
        service
    }
}
