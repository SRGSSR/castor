# Playback Speed

@Metadata {
    @PageColor(purple)
}

Control the pace at which content is played.

## Overview

Many users prefer playing content at customized speeds, whether faster or slower. You can adjust the playback speed of a ``CastPlayer`` programmatically at any time and optionally provide controls to allow users to modify the playback speed themselves.

### Adjust the playback speed programmatically

Playback speed is part of the essential properties automatically published by a ``CastPlayer`` instance, as detailed in the <doc:state-observation-article> article. SwiftUI views observing a player instance will automatically update when the playback speed changes.

To adjust the playback speed programmatically, use the ``CastPlayer/playbackSpeed`` property. You can retrieve the available speed range with ``CastPlayer/playbackSpeedRange``.

> Tip: For custom user interfaces built in SwiftUI, use ``CastPlayer/playbackSpeed``. This provides a binding to the current playback speed, ensuring seamless integration with SwiftUI views.

### Provide speed controls

When building a playback user interface, one of the most common requirements is to provide users with the ability to change the playback speed.

For a quick implementation, you can use the standard system player experience by calling ``CastPlayer/standardSettingsMenu(speeds:action:)``. Wrap the returned view in a [Menu](https://developer.apple.com/documentation/swiftui/menu) that offers not only playback speed selection but also media options for audible and legible characteristics.

If you want more customization, you can create your own menu using ``CastPlayer/playbackSpeedMenu(speeds:action:)``. This allows you to tailor the list of speed options to your app’s needs.

For a fully custom solution, you can design a bespoke media selection interface using the playback speed APIs described above.
