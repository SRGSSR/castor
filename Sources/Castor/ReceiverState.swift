//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@propertyWrapper
final class _ReceiverState<Instance, Recipe>: NSObject where Recipe: SynchronizerRecipe, Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private var recipe: Recipe?

    var service: Recipe.Service? {
        get {
            recipe?.service
        }
        set {
            if let newValue {
                let recipe = Recipe(service: newValue) { [weak self] status in
                    self?.update(with: status)
                } completion: { [weak self] in
                    self?.completion()
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

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, Recipe.Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, _ReceiverState>
    ) -> Recipe.Value {
        get {
            let synchronizer = instance[keyPath: storageKeyPath]
            synchronizer.enclosingInstance = instance
            return synchronizer.value
        }
        set {
            let synchronizer = instance[keyPath: storageKeyPath]
            synchronizer.enclosingInstance = instance
            synchronizer.requestUpdate(to: newValue)
        }
    }

    @available(*, unavailable, message: "@ReceiverState can only be applied to classes")
    var wrappedValue: Recipe.Value {
        get { fatalError() }
        set { fatalError() }
    }

    init(_ recipe: Recipe.Type) {
        self.value = Recipe.defaultValue
    }

    func requestUpdate(to value: Recipe.Value) {
        guard canMakeRequest(), self.value != value else { return }
        if !isRequesting {
            isRequesting = true
            makeRequest(to: value)
        }
        else {
            self.value = value
            pendingValue = value
        }
    }

    private func update(with status: Recipe.Status?) {
        guard let recipe, !isRequesting else { return }
        value = recipe.value(from: status, defaultValue: Recipe.defaultValue)
    }

    private func completion() {
        if let pendingValue {
            makeRequest(to: pendingValue)
            self.pendingValue = nil
        }
        else {
            isRequesting = false
        }
    }

    func canMakeRequest() -> Bool {
        guard let recipe, let requester = recipe.requester else { return false }
        return recipe.canMakeRequest(using: requester)
    }

    private func makeRequest(to value: Recipe.Value) {
        guard let recipe, let requester = recipe.requester else { return }
        self.value = value
        recipe.makeRequest(for: value, using: requester)
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias ReceiverState<Recipe: SynchronizerRecipe> = _ReceiverState<Self, Recipe>
}
