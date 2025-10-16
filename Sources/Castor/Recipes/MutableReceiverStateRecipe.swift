//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol MutableReceiverStateRecipe: ReceiverStateCommonRecipe {
    init(service: Service, update: @escaping (Status) -> Void, completion: @escaping (Bool) -> Void)

    func requestUpdate(to value: Value) -> Bool
}
