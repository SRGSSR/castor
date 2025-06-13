//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@propertyWrapper
final class MutableReceiverStatePropertyWrapper<Instance, Recipe>: NSObject
where Recipe: MutableReceiverStateRecipe, Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private var recipe: Recipe?

    private var isRequesting = false
    private var pendingValue: Recipe.Value?

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
        get { fatalError("Not available") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Not available") }
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

    private func requestUpdate(to value: Recipe.Value) {
        guard self.value != value, let recipe else { return }
        if !isRequesting {
            guard requestUpdate(to: value, with: recipe) else { return }
            isRequesting = true
            self.value = value
        }
        else {
            self.value = value
            pendingValue = value
        }
    }

    private func requestUpdate(to value: Recipe.Value, with recipe: Recipe) -> Bool {
        recipe.requestUpdate(to: value) { [weak self] success in
            self?.completion(success)
        }
    }

    private func update(with status: Recipe.Status?) {
        guard !isRequesting else { return }
        value = Recipe.value(from: status)
    }

    private func completion(_ success: Bool) {
        guard success else {
            pendingValue = nil
            isRequesting = false
            return
        }
        guard let pendingValue else {
            isRequesting = false
            return
        }
        if let recipe, requestUpdate(to: pendingValue, with: recipe) {
            self.value = pendingValue
        }
        self.pendingValue = nil
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, Recipe.Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, MutableReceiverStatePropertyWrapper>
    ) -> Recipe.Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
            return storage.value
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
            storage.requestUpdate(to: newValue)
        }
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias MutableReceiverState<Recipe: MutableReceiverStateRecipe> = MutableReceiverStatePropertyWrapper<Self, Recipe>
}
