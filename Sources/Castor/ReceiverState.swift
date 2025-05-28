//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

@propertyWrapper
final class _ReceiverState<Instance, Recipe>: NSObject, GCKRequestDelegate where Recipe: SynchronizerRecipe, Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private var recipe: Recipe?

    var service: Recipe.Service? {
        get {
            recipe?.service
        }
        set {
            if let newValue {
                let recipe = Recipe(service: newValue, update: update(with:))
                self.recipe = recipe
                value = recipe.value(from: newValue, defaultValue: Recipe.defaultValue)
            }
            else {
                recipe = nil
                value = Recipe.defaultValue
            }
        }
    }

    private weak var currentRequest: GCKRequest?
    private var pendingValue: Recipe.Value?

    var isConnected: Bool {
        service?.requester != nil
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
        guard isConnected, self.value != value else { return }
        self.value = value

        if currentRequest == nil {
            currentRequest = makeRequest(to: value)
        }
        else {
            pendingValue = value
        }
    }

    private func update(with status: Recipe.Service.Status?) {
        guard let recipe, currentRequest == nil else { return }
        value = recipe.value(from: status, defaultValue: Recipe.defaultValue)
    }

    private func makeRequest(to value: Recipe.Value) -> GCKRequest? {
        guard let recipe, let requester = recipe.service.requester else { return nil }
        self.value = value
        let request = recipe.makeRequest(for: value, using: requester)
        request.delegate = self
        return request
    }

    func requestDidComplete(_ request: GCKRequest) {
        if let pendingValue {
            currentRequest = makeRequest(to: pendingValue)
            self.pendingValue = nil
        }
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias ReceiverState<Recipe: SynchronizerRecipe> = _ReceiverState<Self, Recipe>
}
