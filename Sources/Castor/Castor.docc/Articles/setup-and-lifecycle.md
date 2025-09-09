# Setup and Lifecycle

@Metadata {
    @PageColor(purple)
}

Integrate Google Cast into an iOS application using the ``Castor`` SDK.

## Overview

To integrate Google Cast into an iOS application with ``Castor``, you must first configure your project correctly. This includes obtaining the App ID for your receiver, adding the necessary network permissions in the _Info.plist_, and initializing the Cast context at launch.

## Configure the project

The App ID allows the application to identify and communicate with the designated receiver, while the network permissions ensure the app can discover and connect to compatible devices on the local network.

### Get the App ID

If you do not yet have an App ID, you can [create one](https://developers.google.com/cast/codelabs/cast-receiver#3) via the Google Cast Developer Console. You can also use the default App ID provided by Google: `CC1AD845`.

### Configure the _Info.plist_ file

After obtaining your App ID, you must configure the _Info.plist_ file as follows:

```xml
<key>NSBonjourServices</key>
<array>
  <string>_googlecast._tcp</string>
  <string>_<YOUR_APP_ID>._googlecast._tcp</string> <!-- Replace <YOUR_APP_ID> by CC1AD845 (default App ID) or your own App ID -->
</array>

<key>NSLocalNetworkUsageDescription</key>
<string>${PRODUCT_NAME} uses the local network to discover Cast-enabled devices on your WiFi network.</string>
```

These entries are required for iOS to allow local network access and device discovery using _Bonjour_.

### Add the dependency using SPM

You can add ``Castor`` to your iOS project using SPM directly in Xcode. Simply provide the ``Castor`` GitHub repository [URL](https://github.com/SRGSSR/castor).

### Initialize the Google Cast SDK

Next, the Google Cast SDK must be initialized at application launch.

Here is an example of initialization in the `UIApplicationDelegate`:

```swift
import GoogleCast 

func application(
    _ application: UIApplication, 
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
) -> Bool {
    let criteria = GCKDiscoveryCriteria(applicationID: <#"CC1AD845"#>)
    let options = GCKCastOptions(discoveryCriteria: criteria)
    options.physicalVolumeButtonsWillControlDeviceVolume = true
    GCKCastContext.setSharedInstanceWith(options)
    return true
}
```

> Tip: To ensure compatibility with Android TV receivers, enable the following option:
>
> ```swift
> options.launchOptions?.androidReceiverCompatible = true
> ```

## Lifecycle management

Once the project is properly configured and the Google Cast SDK is initialized, the next step is to integrate ``Castor`` itself. ``Castor`` provides a high-level abstraction around the `GoogleCast` SDK, centralizing the logic for discovery, connection, and session management through its core component: the ``Cast`` object.

### Initialization

The ``Cast`` object is the central entry point of the Castor library. It acts as an observable object that integrates directly with the Google Cast SDK and exposes a higher-level API.

A ``Cast`` instance is responsible for:

- Discovering and managing available devices on the local network  
- Starting and ending sessions with a selected device  
- Exposing the active session and its connection state  
- Controlling volume and mute state on the receiver  
- Handling media playback through the associated ``CastPlayer``  
- Notifying the application about lifecycle events via its delegate.

By storing the ``Cast`` instance at the top level of your application, you ensure that session management and device discovery remain active throughout the app lifecycle.

Here is an example:

```swift
import Castor
import SwiftUI

@main
struct MyApp: App {
    // Ensures the Cast instance lives for the whole app lifecycle.
    @StateObject private var cast = Cast()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Injects it into SwiftUI's environment 
                // so that any child view can use 
                // @EnvironmentObject var cast: Cast
                // to access devices, session state, and CastPlayer.
                .environmentObject(cast)
        }
    }
}
```

### Establish a session

Once your ``Cast`` object is initialized and available in your ``SwiftUI`` views, you can start a ``Cast`` session in two main ways:

1. Using the ``CastButton``  
    This button automatically displays available devices and allows the user to initiate a session by selecting a device.
2. Manually listing devices
    You can access the list of available devices via the ``Cast`` object and start a session programmatically using ``Cast/startSession(with:)``.

### Load content

Once a ``Cast`` session is established, you can load media content onto the receiver using the ``CastPlayer`` associated with your ``Cast`` object using ``CastPlayer/loadItem(from:with:)``.

### Handle session events

Once the ``Cast`` object is instantiated and injected into the environment, your app needs a way to respond to session lifecycle events. ``Castor`` provides two protocols for this: ``CastDelegate`` and ``Castable``.

### CastDelegate

This protocol is designed for global session handling, often implemented by a top-level object like a router. Its ``CastDelegate/castEndSession(with:)`` method provides a ``CastResumeState`` when a session stops, so your app can decide how to handle playback resumption.

### Castable

This protocol is intended for playback-related contexts, typically views or objects managing media playback.

- **Session start**: ``Castable/castStartSession()`` returns a ``CastResumeState`` that enables seamless transfer of local playback to a Cast receiver, including synchronization of position, selected audio and subtitles tracks.
- **Session end**: ``Castable/castEndSession(with:)`` receives the ``CastResumeState``, to synchronize playback in the opposite direction, from the remote Cast session back to the local player.

By using both protocols, you can clearly separate responsibilities:

- ``CastDelegate`` manages cast session transitions at the app level, handling navigation, UI updates, and other global behaviors.
- ``Castable`` manages cast session transitions at the view level, handling synchronization between a local player and a remote player.

> Note:
> The ``SwiftUICore/View/supportsCast(_:with:)`` and ``SwiftUICore/View/makeCastable(_:with:)`` view modifiers provide a convenient way to make a ``SwiftUI`` view respond to ``CastDelegate`` events or become ``Castable``.
