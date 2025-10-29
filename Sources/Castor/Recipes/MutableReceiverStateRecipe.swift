//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol MutableReceiverStateRecipe: ReceiverStateRecipe {
    var completion: ((Bool) -> Void)? { get set }

    func requestUpdate(to value: Value) -> Bool
}
