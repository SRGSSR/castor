//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol MutableReceiverStateRecipe2 {
    associatedtype Service
    associatedtype Value: Equatable

    static var defaultValue: Value { get }
}
