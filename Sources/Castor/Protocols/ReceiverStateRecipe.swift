//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol ReceiverStateRecipe: AnyObject {
    associatedtype Service

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    init(service: Service, update: @escaping (Status) -> Void)

    static func status(from service: Service) -> Status
    static func value(from status: Status) -> Value
}

extension ReceiverStateRecipe {
    static func value(from service: Service) -> Value {
        value(from: status(from: service))
    }

    static func value(from status: Status?) -> Value {
        guard let status else { return defaultValue }
        return value(from: status)
    }
}

extension ReceiverStateRecipe where Status == Value {
    static func value(from status: Status) -> Value {
        status
    }
}
