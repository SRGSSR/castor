//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Custom data.
public struct CastCustomData {
    let jsonObject: Any?

    fileprivate init<T>(with object: T, using encoder: JSONEncoder) where T: Encodable {
        if let encodedData = try? encoder.encode(object) {
            self.jsonObject = try? JSONSerialization.jsonObject(with: encodedData)
        }
        else {
            self.jsonObject = nil
        }
    }

    init(jsonObject: Any) {
        self.jsonObject = jsonObject
    }

    /// Decode the data as a given type.
    ///
    /// - Parameters:
    ///   - type: The type to decode to.
    ///   - decoder: The decoder to use.
    ///
    /// Returns `nil` if decoding failed.
    public func decoded<T>(as type: T.Type, using decoder: JSONDecoder = .init()) -> T? where T: Decodable {
        guard let jsonObject, JSONSerialization.isValidJSONObject(jsonObject),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil
        }
        return try? decoder.decode(type.self, from: jsonData)
    }
}

public extension Encodable {
    /// Produces a custom data using the provided encoder.
    func encoded(using encoder: JSONEncoder) -> CastCustomData {
        .init(with: self, using: encoder)
    }
}
