//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol MutableSynchronizerRecipe: SynchronizerRecipe {
    func makeRequest(for value: Value, completion: @escaping (Bool) -> Void) -> Bool
}
