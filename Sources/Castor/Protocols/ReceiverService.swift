//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol ReceiverService {
    associatedtype Status
    associatedtype Requester: ReceiverRequester

    var requester: Requester? { get }

    func status(from requester: Requester) -> Status?
}

extension ReceiverService {
    var isConnected: Bool {
        requester?.canRequest == true
    }
}
