//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol SynchronizerRecipe: AnyObject {
    associatedtype Service: ReceiverService
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    var service: Service { get }

    init(service: Service, update: @escaping (Service.Status?) -> Void)

    func value(from status: Service.Status) -> Value
    func makeRequest(for value: Value, using requester: Service.Requester) -> GCKRequest?
}

extension SynchronizerRecipe {
    func value(from service: Service, defaultValue: Value) -> Value {
        guard let requester = service.requester else { return defaultValue }
        return value(from: service.status(from: requester), defaultValue: defaultValue)
    }

    func value(from status: Service.Status?, defaultValue: Value) -> Value {
        guard let status else { return defaultValue }
        return value(from: status)
    }
}
