//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol ReceiverStateRecipe: ReceiverStateCommonRecipe {
    init(service: Service, update: @escaping (Status) -> Void)
}
