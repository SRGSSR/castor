//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct CastCustomData {
    let data: Any?      // Data?

    fileprivate init<T>(from object: T, using encoder: JSONEncoder) where T: Encodable {
        if let encodedData = try? encoder.encode(object) {
            self.data = try? JSONSerialization.jsonObject(with: encodedData)
        }
        else {
            self.data = nil
        }
    }

    init(data: Any) {
        self.data = data
    }

    public func decoded<T>(as type: T.Type, using decoder: JSONDecoder = .init()) -> T? where T: Decodable {
        guard let data, JSONSerialization.isValidJSONObject(data), let jsonData = try? JSONSerialization.data(withJSONObject: data) else { return nil }
        return try? decoder.decode(type.self, from: jsonData)
    }
}

public extension Encodable {
    func encoded(using encoder: JSONEncoder) -> CastCustomData {
        .init(from: self, using: encoder)
    }
}
