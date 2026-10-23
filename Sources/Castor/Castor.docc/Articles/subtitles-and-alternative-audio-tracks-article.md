# Subtitles and Alternative Audio Tracks

@Metadata {
    @PageColor(purple)
}

Enable users to enjoy content in their preferred language by managing subtitles and alternative audio tracks.

## Overview

Media selection refers to managing options that share the same [AVMediaCharacteristic](https://developer.apple.com/documentation/avfoundation/avmediacharacteristic), such as legible (subtitles) or audible (audio tracks).

### Manage media selection programmatically

Media selection is a core property of a ``CastPlayer`` instance and is automatically published, as detailed in <doc:state-observation-article>. SwiftUI views observing a ``CastPlayer`` instance will automatically update when media selection options or the current selection changes.

Use the following APIs to manage media selection programmatically:

- **List Options:** Retrieve available options for a characteristic using ``CastPlayer/mediaSelectionOptions(for:)``.
- **Get Current Selection:** Access the current selection with ``CastPlayer/selectedMediaOption(for:)``.
- **Update Selection:** Change the selection with ``CastPlayer/select(mediaOption:for:)``. To identify available characteristics, first check ``CastPlayer/mediaSelectionCharacteristics``.

> Tip: When using SwiftUI, leverage ``CastPlayer/mediaOption(for:)``, which provides a binding to the current selection for a characteristic.

### Set preferred languages and characteristics

To override default preferences, call ``CastPlayer/setMediaSelectionPreference(_:for:)``. Preferences can be updated during playback or configured beforehand, which is useful if your app includes a custom language preference setting that should take precedence over default choices.

### Display media selection

For most playback user interfaces, all you need is a way to let users switch subtitles or audio tracks:

- To replicate the standard system player experience, use ``CastPlayer/standardSettingsMenu(speeds:action:)`` and embed its result in a [Menu](https://developer.apple.com/documentation/swiftui/menu). This menu includes options for media selection and playback speed.
- To customize menus further, use ``CastPlayer/mediaSelectionMenu(characteristic:action:)`` to retrieve a submenu for a specific characteristic.
- For complete control, use the media selection APIs to build a fully custom interface.

### Transfer playback between sender and receiver

When starting a Cast session, the audio and subtitle selections stored in the ``CastResumeState`` returned by ``Castable/castStartSession()`` are automatically applied when playback resumes on the receiver. When ending a session, the ``CastResumeState`` received by ``Castable/castEndSession(with:)`` contains the active selections, which you can use to restore them in your local player if playback should continue on the sender.
