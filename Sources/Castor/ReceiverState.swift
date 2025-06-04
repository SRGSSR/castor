//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@propertyWrapper
final class ReceiverStatePropertyWrapper<Instance, Recipe>: NSObject
where Recipe: SynchronizerRecipe, Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private var recipe: Recipe?

    var service: Recipe.Service? {
        get {
            recipe?.service
        }
        set {
            if let newValue {
                let recipe = Recipe(service: newValue) { [weak self] status in
                    self?.update(with: status)
                }
                self.recipe = recipe
                value = recipe.value(from: newValue, defaultValue: Recipe.defaultValue)
            }
            else {
                recipe = nil
                value = Recipe.defaultValue
            }
        }
    }

    private weak var enclosingInstance: Instance?

    @Published private var value: Recipe.Value {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    var projectedValue: AnyPublisher<Recipe.Value, Never> {
        $value.eraseToAnyPublisher()
    }

    @available(*, unavailable, message: "@ReceiverState can only be applied to classes")
    var wrappedValue: Recipe.Value {
        fatalError("Not available")
    }

    init(_ recipe: Recipe.Type) {
        self.value = Recipe.defaultValue
    }

    private func update(with status: Recipe.Status?) {
        guard let recipe else { return }
        value = recipe.value(from: status, defaultValue: Recipe.defaultValue)
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: KeyPath<Instance, Recipe.Value>,
        storage storageKeyPath: KeyPath<Instance, ReceiverStatePropertyWrapper>
    ) -> Recipe.Value {
        get {
            let synchronizer = instance[keyPath: storageKeyPath]
            synchronizer.enclosingInstance = instance
            return synchronizer.value
        }
        // swiftlint:disable:next unused_setter_value
        set {}
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias ReceiverState<Recipe: SynchronizerRecipe> = ReceiverStatePropertyWrapper<Self, Recipe>
}
