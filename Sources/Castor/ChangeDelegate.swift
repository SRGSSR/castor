//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol ChangeDelegate: AnyObject {
    // TODO: Maybe rename to better reflect the fact this value is changed remotely, e.g. didReceiveUpdate()
    func didChange()
}
