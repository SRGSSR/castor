//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol MutableReceiverStateRecipe: ReceiverStateRecipe {
    func makeRequest(for value: Value, completion: @escaping (Bool) -> Void) -> Bool
}
