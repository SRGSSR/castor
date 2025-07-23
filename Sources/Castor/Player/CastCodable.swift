//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public protocol CastCodable: Codable {
    static var encoder: JSONEncoder { get }
    static var decoder: JSONDecoder { get }
}

public extension CastCodable {
    static var encoder: JSONEncoder {
        .init()
    }

    static var decoder: JSONDecoder {
        .init()
    }
}

extension CastCodable {
    func encodeToJSON() -> Any? {
        guard let data = try? JSONEncoder().encode(self), let serialized = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return serialized
    }

    static func decode(fromJSONObject JSONObject: Any?) -> Self? {
        guard let JSONObject, let data = try? JSONSerialization.data(withJSONObject: JSONObject) else { return nil }
        return try? Self.decoder.decode(Self.self, from: data)
    }
}
