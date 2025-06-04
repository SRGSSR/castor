//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol BaseSynchronizerRecipe: AnyObject {
    associatedtype Service

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    var service: Service { get }

    static func status(from service: Service) -> Status?
    static func value(from status: Status) -> Value
}

extension BaseSynchronizerRecipe where Status == Value {
    static func value(from status: Status) -> Value {
        status
    }
}

extension BaseSynchronizerRecipe where Optional<Status> == Value {
    static func value(from status: Status) -> Value {
        status
    }
}

extension BaseSynchronizerRecipe {
    func value(from service: Service, defaultValue: Value) -> Value {
        value(from: Self.status(from: service), defaultValue: defaultValue)
    }

    func value(from status: Status?, defaultValue: Value) -> Value {
        guard let status else { return defaultValue }
        return Self.value(from: status)
    }
}
