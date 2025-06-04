//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

// TODO: Inherit from SynchronizerRecipe
protocol MutableSynchronizerRecipe: AnyObject {
    associatedtype Service
    associatedtype Requester

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    var service: Service { get }
    var requester: Requester? { get }

    // TODO: Is there a better/safer way to handle completion?
    init(service: Service, update: @escaping (Status?) -> Void, completion: @escaping () -> Void)

    static func status(from service: Service) -> Status?
    static func value(from status: Status) -> Value
    
    func makeRequest(for value: Value, using requester: Requester)
}

extension MutableSynchronizerRecipe where Service == Requester {
    var requester: Requester? {
        service
    }
}

extension MutableSynchronizerRecipe {
    func value(from service: Service, defaultValue: Value) -> Value {
        return value(from: Self.status(from: service), defaultValue: defaultValue)
    }

    func value(from status: Status?, defaultValue: Value) -> Value {
        guard let status else { return defaultValue }
        return Self.value(from: status)
    }
}
