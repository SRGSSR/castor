//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

// TODO: Status? vs Status in signatures
protocol SynchronizerRecipe: AnyObject {
    associatedtype Service
    associatedtype Requester

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    var service: Service { get }

    // TODO: Is this really needed now???
    var requester: Requester? { get }

    init(service: Service, update: @escaping (Status?) -> Void, completion: @escaping () -> Void)

    // TODO: Could we merge these two methods somehow?
    static func status(from requester: Requester) -> Status?
    static func value(from status: Status) -> Value

    // TODO: Maybe there is a better way to handle request availability?
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
