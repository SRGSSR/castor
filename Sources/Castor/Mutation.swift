//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Mutation<Element>: Equatable where Element: Hashable {
    case move(element: Element, before: Element?)
    case remove(element: Element)

    static func mutations(from initial: [Element], to final: [Element]) -> [Self] {
        var mutations: [Mutation<Element>] = []
        var intermediate = initial
        final.difference(from: initial).inferringMoves().forEach { change in
            switch change {
            case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                if associatedWith != nil {
                    mutations.append(.move(element: element, before: intermediate[safeIndex: offset]))
                }
                intermediate.insert(element, at: offset)
            case let .remove(offset: offset, element: element, associatedWith: associatedWith):
                if associatedWith == nil {
                    mutations.append(.remove(element: element))
                }
                intermediate.remove(at: offset)
            }
        }
        return mutations
    }
}
