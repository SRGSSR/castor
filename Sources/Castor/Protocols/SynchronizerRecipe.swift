//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol SynchronizerRecipe: AnyObject {
    associatedtype Service

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    init(service: Service, update: @escaping (Status?) -> Void)

    static func status(from service: Service) -> Status?
    static func value(from status: Status) -> Value

    func detach()
}

extension SynchronizerRecipe where Value == Status {
    static func value(from status: Status) -> Value {
        status
    }
}

extension SynchronizerRecipe where Value == Status? {
    static func value(from status: Status) -> Value {
        status
    }
}

extension SynchronizerRecipe {
    func detach() {}
}

extension SynchronizerRecipe {
    func value(from service: Service, defaultValue: Value) -> Value {
        value(from: Self.status(from: service), defaultValue: defaultValue)
    }

    func value(from status: Status?, defaultValue: Value) -> Value {
        guard let status else { return defaultValue }
        return Self.value(from: status)
    }
}
