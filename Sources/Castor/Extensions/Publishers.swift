//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

extension Publisher {
    func weakCapture<T, V>(_ other: T?, at keyPath: KeyPath<T, V>) -> AnyPublisher<(Output, V), Failure> where T: AnyObject {
        compactMap { [weak other] output -> (Output, V)? in
            guard let other else { return nil }
            return (output, other[keyPath: keyPath])
        }
        .eraseToAnyPublisher()
    }

    func weakCapture<T>(_ other: T?) -> AnyPublisher<(Output, T), Failure> where T: AnyObject {
        weakCapture(other, at: \T.self)
    }
}
