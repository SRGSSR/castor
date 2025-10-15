//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@MainActor
@propertyWrapper
final class MutableReceiverStatePropertyWrapper2<Instance, Value>: NSObject
where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher, Value: Equatable {
    private weak var enclosingInstance: Instance?

    @Published private var value: Value {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    var wrappedValue: Value {
        get { fatalError("Not available") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Not available") }
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, MutableReceiverStatePropertyWrapper2>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
            return storage.value
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
        }
    }

    func synchronize<Recipe, Service>(
        using recipe: Recipe.Type,
        service: Service
    ) where Recipe: MutableReceiverStateRecipe2, Recipe.Service == Service, Recipe.Value == Value {
        value = Recipe.defaultValue
        // ...
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias MutableReceiverState2<Value> = MutableReceiverStatePropertyWrapper2<Self, Value> where Value: Equatable
}
