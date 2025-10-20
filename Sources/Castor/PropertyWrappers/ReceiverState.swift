//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@MainActor
@propertyWrapper
final class ReceiverStatePropertyWrapper<Instance, Value>: NSObject
where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private let recipe: any ReceiverStateRecipe

    private weak var enclosingInstance: Instance?

    @Published private var value: Value {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        $value.eraseToAnyPublisher()
    }

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    var wrappedValue: Value {
        fatalError("Not available")
    }

    init<Recipe, Service>(
        service: Service,
        recipe: Recipe.Type
    ) where Recipe: ReceiverStateRecipe, Recipe.Service == Service, Recipe.Value == Value {
        let recipe = Recipe(service: service)

        self.recipe = recipe
        self.value = Recipe.defaultValue
        super.init()

        recipe.update = { [weak self] status in
            self?.value = Recipe.value(from: status)
        }
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: KeyPath<Instance, Value>,
        storage storageKeyPath: KeyPath<Instance, ReceiverStatePropertyWrapper>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
            return storage.value
        }
        // swiftlint:disable:next unused_setter_value
        set {}
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias ReceiverState<Value> = ReceiverStatePropertyWrapper<Self, Value>
}
