//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol MutableSynchronizerRecipe: AnyObject {
    associatedtype Service

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    var service: Service { get }

    init(service: Service, update: @escaping (Status?) -> Void, completion: @escaping () -> Void)

    static func status(from service: Service) -> Status?
    static func value(from status: Status) -> Value

    // TODO: Maybe there is a better way to handle request availability?
    func canMakeRequest(using service: Service) -> Bool
    func makeRequest(for value: Value, using service: Service)
}

extension MutableSynchronizerRecipe {
    func canMakeRequest(using requester: GCKSessionManager) -> Bool {
        true
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
