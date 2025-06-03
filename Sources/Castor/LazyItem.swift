//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

@propertyWrapper
final class LazyItemPropertyWrapper<Instance>: NSObject, GCKMediaQueueDelegate where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private let id: GCKMediaQueueItemID
    private let queue: GCKMediaQueue
    private weak var enclosingInstance: Instance?

    @available(*, unavailable, message: "@LazyItem can only be applied to classes")
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
        super.init()
        queue.add(self)
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
        set {}
    }

    // TODO: Maybe we can refresh the cache now with each fetch.
    func fetch() {
        guard value == nil else { return }
        if let item = queue.item(withID: id, fetchIfNeeded: false) {
            value = item
        }
        else {
            queue.item(withID: id)
        }
    }

    func release() {
        queue.remove(self)
    }

    func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        if let item = queue.item(withID: id, fetchIfNeeded: false) {
            value = item
        }
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias LazyItem = LazyItemPropertyWrapper<Self>
}
