//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

@propertyWrapper
final class CurrentDevicePropertyWrapper<Instance>: NSObject, GCKSessionManagerListener
where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private let service: GCKSessionManager
    private weak var enclosingInstance: Instance?
    private var targetValue: CastDevice?

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    var wrappedValue: CastDevice? {
        get { fatalError("Not available") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Not available") }
    }

    @Published private var value: CastDevice? {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    init(service: GCKSessionManager) {
        self.service = service
        super.init()
        value = Self.device(from: service.currentCastSession)
        service.add(self)
    }

    private static func device(from session: GCKCastSession?) -> CastDevice? {
        session?.device.toCastDevice()
    }

    private func requestUpdate(to value: CastDevice?) {
        guard let value, self.value != value else { return }
        moveSession(from: self.value, to: value)
        self.value = value
    }

    private func moveSession(from previousValue: CastDevice?, to currentValue: CastDevice) {
        if previousValue != nil {
            targetValue = currentValue
            service.endSession()
        }
        else {
            service.startSession(with: currentValue.rawDevice)
        }
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        value = Self.device(from: session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        if let targetValue {
            service.startSession(with: targetValue.rawDevice)
            self.targetValue = nil
        }
        else {
            value = nil
        }
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        value = nil
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, CastDevice?>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, CurrentDevicePropertyWrapper>
    ) -> CastDevice? {
        get {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
            return storage.value
        }
        set {
            let storage = instance[keyPath: storageKeyPath]
            storage.enclosingInstance = instance
            storage.requestUpdate(to: newValue)
        }
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias CurrentDevice = CurrentDevicePropertyWrapper<Self>
}
