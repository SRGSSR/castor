# Playback

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: playback-card, alt: "A clapperboard image.")
}

Play audio and video content with ease.

## Overview

Use a ``CastPlayer`` to manage playback of one or more media assets sequentially, and receive automatic updates about playback state changes.

> Important: ``CastPlayer`` cannot be instantiated manually, it must be retrieved from the ``Cast`` object.

## Load content

A content that can be played in the ``Cast`` universe is called a ``CastAsset``. Assets can be represented in three forms:

- **Entity**: It is a deep link URL that represents a single media item and that your receiver should be able to handle.
- **Identifier**: A unique ID for that represents a single media item and that your receiver should be able to handle.
- **URL**: The direct URL of the content. This asset type may require additional configuration, which can be provided via ``CastAssetURLConfiguration``.

> Warning: Playing a media URL directly can sometimes be tricky. For example, if you try to play an HLS URL directly, the Cast receiver might not respond correctly. This is because the receiver often requires additional information, such as the MIME type and the type of audio and video segments, to handle the stream properly. You can provide this information using the ``CastAsset/url(_:configuration:metadata:customData:)-6xskn`` initializer along with a ``CastAssetURLConfiguration``.

You can load one or several items from media assets. Since ``CastPlayer`` conforms to [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject) and cannot be instantiated manually, it should be stored as an [`ObservedObject`](https://developer.apple.com/documentation/swiftui/observedobject) within a SwiftUI view. This ensures the player's lifecycle aligns with the view and that UI updates automatically reflect changes in playback state.

@TabNavigator {
    @Tab("Single item") {
        Load a player with a single item.

        ```swift
        struct PlayerView: View {
            @ObservedObject var player: CastPlayer

            Button {
                player.loadItem(from: .url(URL(string: "https://server.com/stream_1.m3u8")!, metadata: nil))
            } label: {
                Text("Load")
            }
        }
        ```
    }

    @Tab("Multiple items") {
        Load a player with multiple items.

        ```swift
        struct PlayerView: View {
            @ObservedObject var player: CastPlayer
            
            Button {
                player.loadItems(from: [
                    .url(URL(string: "https://server.com/stream_1.m3u8")!, metadata: nil),
                    .url(URL(string: "https://server.com/stream_2.m3u8")!, metadata: nil)
                ])
            } label: {
                Text("Load")
            }
        }
        ```
    }
}

> Tip: For more details on observing player state updates, refer to the <doc:state-observation-article> article.

## Auto start playback

When an asset is loaded, the player automatically starts in the playing state. There is no need to explicitly call ``CastPlayer/play()``. This behavior is intentional, loading a content is considered a strong playback intent. In most scenarios, users expect media to start immediately once a selection is made. If you need to load content without starting playback immediately, you can pause the player right after loading by observing changes in ``CastPlayer/currentItem`` and calling ``CastPlayer/pause()`` when the current item is not nil.

## Playlist

The ``CastPlayer`` supports queue-based playback, allowing you to manage multiple media assets in a playlist. You can load multiple assets at once, append or prepend items, and navigate through the queue with ease.

### Managing items

The playback queue can be accessed via the ``CastPlayer/items`` property. You can modify the queue using the API to append, prepend, insert, or remove items as needed.

@TabNavigator {
    @Tab("Append or prepend items") {
        Add new items to the front or back of the queue.

        ```swift
        player.prependItem(from: .url(URL(string: "https://server.com/stream_0.m3u8")!, metadata: nil))
        player.appendItem(from: .url(URL(string: "https://server.com/stream_5.m3u8")!, metadata: nil))
        ```
    }
    
    @Tab("Insert item") {
        Insert before or after a specific item in the queue.

        ```swift
        player.insertItem(from: .url(URL(string: "https://server.com/stream_4.m3u8")!, metadata: nil), before: player.items.last)
        player.insertItem(from: .url(URL(string: "https://server.com/stream_6.m3u8")!, metadata: nil), after: player.items.last)
        ```
    }
    
    @Tab("Remove items") {
        Remove a specific item or clear the entire queue.

        ```swift
        player.remove(player.items.first!)
        player.removeAllItems()
        ```
    }
}

### Navigating

You can programmatically navigate through the playlist, moving forward to the next item or backward to the previous item as needed.

> Important: When the last item in the queue is consumed with ``CastPlayer/repeatMode`` ``CastRepeatMode/off``, the ``CastPlayer`` stops and the items are cleared automatically.

@TabNavigator {
    @Tab("Advance to next item") {
        Checks whether we can advance, and if so, moves to the next item.

        ```swift
        if player.canAdvanceToNextItem() {
            player.advanceToNextItem()
        }
        ```
    }
    
    @Tab("Return to previous item") {
        Checks whether we can return, and if so, moves to the previous item.

        ```swift
        if player.canReturnToPreviousItem() {
            player.returnToPreviousItem()
        }
        ```
    }
}

> Note: When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, both ``CastPlayer/advanceToNextItem()`` and ``CastPlayer/returnToPreviousItem()`` wrap around the queue. This means that returning from the first item moves to the last item, and advancing from the last item moves to the first. These methods ignore the ``CastConfiguration/navigationMode`` set in ``Cast/configuration``. To respect the navigation rules from the configuration, use ``CastPlayer/returnToPrevious()`` and ``CastPlayer/advanceToNext()`` instead.
