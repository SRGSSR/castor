# State Observation

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: state-observation-card, alt: "An eye image.")
}

Learn how to observe and respond to state changes.

## Overview

The ``Castor`` framework leverages [Combine](https://developer.apple.com/documentation/combine), [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject), and published properties, allowing SwiftUI views to automatically react to changes in state:

- ``Cast`` manages all aspects of Google Cast, including the device list, the current device, and the connection state.
- ``CastPlayer`` interacts with a receiver device once a session has been established, handling playback and item management.

### Observe essential states

``Cast`` and ``CastPlayer`` automatically publish essential states, making it straightforward to build device discovery and playback-related UI components with SwiftUI. For example, you can use [`List`](https://developer.apple.com/documentation/swiftui/list) to present available devices or to create a playlist management interface.

Here’s a simple example that observes player state to implement a labeled playback button:

```swift
struct PlaybackButton: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Button(action: player.togglePlayPause) {
            Text(player.shouldPlay ? "Pause" : "Play")
        }
    }
}
```

### Observe time updates

Accurate time tracking is crucial for playback features like progress bars. However, to prevent excessive layout refreshes, a ``CastPlayer`` does not automatically publish time updates.

In SwiftUI, use a ``CastProgressTracker`` to efficiently manage and observe progress changes. When bound to a player, a progress tracker not only provides automatic progress updates but also allows the user to interactively adjust the progress.

### Use SwiftUI property wrappers wisely

 [Proper use](https://developer.apple.com/documentation/swiftui/model-data) of SwiftUI property wrappers ensures efficient UI updates. Below are common patterns associated with player observation:

1. **Player Neither Owned nor Observed:** Pass the player as a constant:

    ```swift
    struct Widget: View {
        let player: CastPlayer

        var body: some View {
            // Not updated when the player publishes changes
        }
    }
    ```

2. **Player Not Owned but Observed:** Receive the player as an `@ObservedObject`:

    ```swift
    struct Widget: View {
        @ObservedObject var player: CastPlayer

        var body: some View {
            // Updated when the player publishes changes
        }
    }
    ```

> Note: Because you never instantiate a ``CastPlayer`` directly—instead using the instance provided by ``Cast``—you will not typically use patterns such as `@State` or `@StateObject` to own a player.
