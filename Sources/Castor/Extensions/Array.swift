//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum Mutation<Element> {
    case move(element: Element, before: Element?)
    case remove(element: Element)
}

extension Array where Element: Hashable {
    func mutations(from other: Array) -> [Mutation<Element>] {
        var mutations: [Mutation<Element>] = []
        var intermediate = other
        difference(from: other).inferringMoves().forEach { change in
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
