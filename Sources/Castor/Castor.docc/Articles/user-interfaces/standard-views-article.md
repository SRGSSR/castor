# User Interface

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: standard-views-card, alt: "An image depicting Google Cast buttons and player views.")
}

Integrate Cast experience in your application.

## Overview

``Castor`` provides modern SwiftUI views that are easier to integrate. APIs are available to create fully custom player interfaces.

## Castor standard views

Castor includes several built-in views to cover common Cast use cases. Below are examples for the main components: ``CastButton``, ``CastMiniPlayerView``, and ``CastPlayerView``.

> Tip: By default, the provided views use the `.accentColor`. You can change this color using the `.foregroundStyle` modifier, but note that this will not affect the color within the child views or a ``SwiftUI/Slider`` color. To update the default `accentColor` in the view displayed by the ``CastButton``, use the `.tint` modifier.

### Cast button

``CastButton`` is a SwiftUI view that displays a receiver selection popover (or a modal sheet, depending on the available width) and automatically reflects the current connection state.

For example, you can add a Cast button to a toolbar as follows:

```swift
struct ContentView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        Color.clear
            .toolbar {
                CastButton(cast: cast)
            }
    }
}
```

> Note: To create a custom Cast button, use ``CastIcon``, which automatically animates according to the current ``Cast/connectionState``. You can then present the list of available ``Cast/devices`` with a custom experience, such as your own device picker.

### Mini and expanded views

> Important: These views will not be displayed unless a connection to a receiver device has been established and a content is being loaded.

<!-- markdownlint-disable MD046 -->
@TabNavigator {
    @Tab("Mini") {
        ``CastMiniPlayerView`` displays a compact view of the current Cast playback. Add the mini player to the bottom of your interface as follows:

        ```swift
        struct ContentView: View {
            @EnvironmentObject private var cast: Cast

            var body: some View {
                Color.clear
                    .safeAreaInset(edge: .bottom) {
                        CastMiniPlayerView(cast: cast)
                    }
            }
        }
        ```
    }

    @Tab("Expanded") {
        ``CastPlayerView`` presents a full player interface with connection status, artwork, and playback controls. Display the expanded player when the mini player is tapped, as follows:

        ```swift
        struct ContentView: View {
            @EnvironmentObject private var cast: Cast
            @State private var isPresented = false

            var body: some View {
                Color.clear
                    .safeAreaInset(edge: .bottom) {
                        CastMiniPlayerView(cast: cast)
                            .onTapGesture { isPresented.toggle() }
                    }
                    .sheet(isPresented: $isPresented) {
                        CastPlayerView(cast: cast)
                    }
            }
        }
        ```
    }
}
<!-- markdownlint-restore -->

## Custom views

If the provided views don't meet your needs, you can create your own custom views from scratch:  

- To implement a Cast device selection list, use ``Cast``. With it, you can list available devices and start or end a session.  
- Once a session is established, the ``Cast`` object exposes a ``Cast/player`` property that provides a ``CastPlayer`` instance. You can use this instance to manage the player state and the item list.  

When building a user interface, you can also use ``CastIcon`` to display the Cast connection state, or ``CastProgressTracker`` to handle playback position—for example, in combination with ``SwiftUI/Slider``.  

## Google Cast views

Google Cast provides default views for sender applications, including the Cast button and mini/expanded player UIs.  

- `GCKUICastButton`  
- `GCKUIStyleAttributesMiniController`  
- `GCKUIStyleAttributesExpandedController`

The default Google Cast views are functional but not very modern appearance and can be challenging to customize. For more details, refer to the Google Cast iOS Sender UI customization [guide](https://developers.google.com/cast/docs/ios_sender/customize_ui#style_hierarchy). Additionally, to integrate these views into a SwiftUI interface, you will need to bridge them using `UIViewRepresentable` or `UIViewControllerRepresentable`.
