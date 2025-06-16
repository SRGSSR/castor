//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

@MainActor @propertyWrapper
final class LazyItemPropertyWrapper<Instance>: NSObject, GCKMediaQueueDelegate
where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private let id: GCKMediaQueueItemID

    // FIXME: Remove "unowned" if the Google Cast SDK is updated to avoid the media queue strongly retaining its delegate.
    private unowned let queue: GCKMediaQueue            // Avoid cyclic reference due to the media queue delegate being retained.

    private weak var enclosingInstance: Instance?

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    var wrappedValue: GCKMediaQueueItem? {
        fatalError("Not available")
    }

    @Published private var value: GCKMediaQueueItem? {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    init(id: GCKMediaQueueItemID, queue: GCKMediaQueue) {
        self.id = id
        self.queue = queue
        self.value = queue.item(withID: id, fetchIfNeeded: false)
        super.init()
        queue.add(self)        // The delegate is retained.
    }

    func fetch() {
        queue.item(withID: id)
    }

    // swiftlint:disable:next legacy_objc_type
    func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        // swiftlint:disable:next legacy_objc_type
        let index = NSNumber(value: queue.indexOfItem(withID: id))
        if indexes.contains(index), let item = queue.item(withID: id, fetchIfNeeded: false) {
            value = item
        }
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: KeyPath<Instance, GCKMediaQueueItem?>,
        storage storageKeyPath: KeyPath<Instance, LazyItemPropertyWrapper>
    ) -> GCKMediaQueueItem? {
        get {
            let wrapper = instance[keyPath: storageKeyPath]
            wrapper.enclosingInstance = instance
            return wrapper.value
        }
        // swiftlint:disable:next unused_setter_value
        set {}
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias LazyItem = LazyItemPropertyWrapper<Self>
}
