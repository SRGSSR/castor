//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol MutableReceiverStateRecipe: ReceiverStateRecipe {
    // TODO: The completion closure possibly does not need to be stored by concrete recipes anymore after refactoring.
    func requestUpdate(to value: Value, completion: @escaping (Bool) -> Void) -> Bool
}
