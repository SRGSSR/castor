# ``Castor/Cast``

## Topics

### Creating an Instance

- ``init(configuration:)``
- ``configuration``

### Managing Sessions

- ``connectionState``
- ``currentDevice``
- ``devices``
- ``endSession()``
- ``isCasting(on:)``
- ``startSession(with:)``

### Managing Paired Devices

- ``multizoneDevices``

### Controlling the Volume

- ``deviceManager(for:)->CastDeviceManager<CastDevice>?``
- ``deviceManager(for:)->CastDeviceManager<CastMultizoneDevice>?``

### Managing the Playback

- ``player``

### Retrieving SDK Information

- ``version``
