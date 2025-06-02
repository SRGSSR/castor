//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol SynchronizerRecipe: AnyObject {
    associatedtype Service
    associatedtype Requester

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    var service: Service { get }
    var requester: Requester? { get }

    init(service: Service, update: @escaping (Status?) -> Void, completion: @escaping () -> Void)

    // TODO: Could likely be static methods

    static func status(from requester: Requester) -> Status?
    static func value(from status: Status) -> Value

    func canMakeRequest(using requester: Requester) -> Bool
    func makeRequest(for value: Value, using requester: Requester)
}

extension SynchronizerRecipe {
    func value(from service: Service, defaultValue: Value) -> Value {
        guard let requester else { return defaultValue }
        return value(from: Self.status(from: requester), defaultValue: defaultValue)
    }

    func value(from status: Status?, defaultValue: Value) -> Value {
        guard let status else { return defaultValue }
        return Self.value(from: status)
    }
}
