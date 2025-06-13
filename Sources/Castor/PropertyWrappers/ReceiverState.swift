//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@propertyWrapper
final class ReceiverStatePropertyWrapper<Instance, Recipe>: NSObject
where Recipe: ReceiverStateRecipe, Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private(set) var recipe: Recipe?

    private weak var enclosingInstance: Instance?

    @Published private var value: Recipe.Value {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    var projectedValue: AnyPublisher<Recipe.Value, Never> {
        $value.eraseToAnyPublisher()
    }

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    var wrappedValue: Recipe.Value {
        fatalError("Not available")
    }

    init(_ recipe: Recipe.Type) {
        self.value = Recipe.defaultValue
    }

    func bind(to service: Recipe.Service) {
        let recipe = Recipe(service: service) { [weak self] status in
            self?.update(with: status)
        }
        self.recipe = recipe
        value = Recipe.value(from: service)
    }

    private func update(with status: Recipe.Status?) {
        value = Recipe.value(from: status)
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: KeyPath<Instance, Recipe.Value>,
        storage storageKeyPath: KeyPath<Instance, ReceiverStatePropertyWrapper>
    ) -> Recipe.Value {
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
    typealias ReceiverState<Recipe: ReceiverStateRecipe> = ReceiverStatePropertyWrapper<Self, Recipe>
}
