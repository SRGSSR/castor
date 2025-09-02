//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Custom data transmitted between a sender and a receiver.
///
/// > Important: Keep the payload size small to avoid exceeding the [maximum transport message size](https://developers.google.com/cast/docs/media/messages)
/// of 64 KB.
public struct CastCustomData {
    let jsonObject: Any?

    fileprivate init<T>(with object: T, using encoder: JSONEncoder) where T: Encodable {
        if let data = try? encoder.encode(object) {
            jsonObject = try? JSONSerialization.jsonObject(with: data)
        }
        else {
            jsonObject = nil
        }
    }

    init(jsonObject: Any) {
        self.jsonObject = jsonObject
    }

    /// Decodes the data as a specified type.
    ///
    /// - Parameters:
    ///   - type: The type to decode to.
    ///   - decoder: The decoder to use.
    ///
    /// - Returns: The decoded value, or `nil` if decoding fails.
    public func decoded<T>(as type: T.Type, using decoder: JSONDecoder = .init()) -> T? where T: Decodable {
        guard let jsonObject, JSONSerialization.isValidJSONObject(jsonObject),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil
        }
        return try? decoder.decode(type.self, from: jsonData)
    }
}

public extension Encodable {
    /// Produces custom data using the provided encoder.
    func encoded(using encoder: JSONEncoder) -> CastCustomData {
        .init(with: self, using: encoder)
    }
}
