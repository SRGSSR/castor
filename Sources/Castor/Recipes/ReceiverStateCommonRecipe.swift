//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@MainActor
protocol ReceiverStateCommonRecipe: AnyObject {
    associatedtype Service

    associatedtype Status
    associatedtype Value: Equatable

    static var defaultValue: Value { get }

    static func status(from service: Service) -> Status
    static func value(from status: Status) -> Value
}

extension ReceiverStateCommonRecipe {
    static func value(from service: Service) -> Value {
        value(from: status(from: service))
    }

    static func value(from status: Status?) -> Value {
        guard let status else { return defaultValue }
        return value(from: status)
    }
}

extension ReceiverStateCommonRecipe where Status == Value {
    static func value(from status: Status) -> Value {
        status
    }
}
