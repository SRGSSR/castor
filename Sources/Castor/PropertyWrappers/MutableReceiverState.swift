//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@MainActor
@propertyWrapper
final class MutableReceiverStatePropertyWrapper<Instance, Value>: NSObject
where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher, Value: Equatable {
    private let recipe: any ReceiverStateRecipe

    private var isRequesting = false
    private var pendingValue: Value?

    private let requestUpdateImp: (Value) -> Bool

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
        get { fatalError("Not available") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Not available") }
    }

    init<Recipe, Service>(
        service: Service,
        recipe: Recipe.Type
    ) where Recipe: MutableReceiverStateRecipe, Recipe.Service == Service, Recipe.Value == Value {
        let recipe = Recipe(service: service)

        self.recipe = recipe
        self.requestUpdateImp = { value in
            recipe.requestUpdate(to: value)
        }
        self.value = Recipe.value(from: service)

        super.init()

        recipe.update = { [weak self] status in
            guard let self, !isRequesting else { return }
            value = Recipe.value(from: status)
        }
        recipe.completion = { [weak self, weak recipe] success in
            guard let self, let recipe else { return }
            guard success else {
                pendingValue = nil
                isRequesting = false
                return
            }
            guard let pendingValue else {
                isRequesting = false
                return
            }
            if recipe.requestUpdate(to: pendingValue) {
                self.value = pendingValue
            }
            self.pendingValue = nil
        }
    }

    private func requestUpdate(to value: Value) {
        guard self.value != value else { return }
        if !isRequesting {
            guard requestUpdateImp(value) else { return }
            isRequesting = true
            self.value = value
        }
        else {
            self.value = value
            pendingValue = value
        }
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, MutableReceiverStatePropertyWrapper>
    ) -> Value {
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
    typealias MutableReceiverState<Value> = MutableReceiverStatePropertyWrapper<Self, Value> where Value: Equatable
}
