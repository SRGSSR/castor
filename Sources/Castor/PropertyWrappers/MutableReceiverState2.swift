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
        recipe.update = { _ in
        }
        recipe.completion = { _ in
        }
        requestUpdateImp = { value in
            recipe.requestUpdate(to: value)
        }
        value = Recipe.value(from: service)
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
            storage.requestUpdate(to: newValue)
        }
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias MutableReceiverState2<Value> = MutableReceiverStatePropertyWrapper2<Self, Value> where Value: Equatable
}
