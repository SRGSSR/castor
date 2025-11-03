# ``Castor``

@Metadata {
    @PageColor(purple)
}

Extend your iOS app to stream video and audio to any Google Cast–compatible receiver.

## Overview

The Castor framework provides a comprehensive set of tools to connect to a Google Cast receiver and control playback with ease:

- Discover available devices and transfer playback between senders and receivers using ``Cast``. Adding a modern device picker is as simple as including a ``CastButton`` in your app.
- Control playback on a connected receiver using a ``CastPlayer``. Load ``CastAsset``s based on entities, identifiers, or URLs. Dynamically add items to playlists, reorder them, or remove them as needed.
- Present a modern playback interface with ``CastPlayerView`` or design your own, either as a standalone experience or tightly integrated with your main player.
- Integrate compact controls using ``CastMiniPlayerView`` or create your own mini player.

@Image(source: player-intro, alt: "A screenshot of the standard player user interface")

The Castor framework integrates seamlessly with SwiftUI, leveraging its declarative and reactive design to accelerate iteration and refinement of your ideas.

> Tip: See the Google Cast SDK [official documentation](https://developers.google.com/cast) for best practices when adding Cast support to your app.

### Featured

@Links(visualStyle: detailedGrid) {
    - <doc:setup-and-lifecycle-article>
    - <doc:playback-article>
    - <doc:user-interface-article>
    - <doc:metadata-article>
    - <doc:state-observation-article>
    - <doc:optimization-article>
}

## Topics

### Session and Device Management

- <doc:setup-and-lifecycle-article>

- ``Cast``
- ``Castable``
- ``CastConfiguration``
- ``CastDelegate``
- ``CastDevice``
- ``CastDeviceManager``
- ``CastMultizoneDevice``
- ``CastResumeState``

### Playback

- <doc:playback-article>
- <doc:playback-speed-article>
- <doc:state-observation-article>
- <doc:subtitles-and-alternative-audio-tracks-article>

- ``CastMediaSelectionOption``
- ``CastMediaSelectionPreference``
- ``CastMediaTrack``
- ``CastNavigationMode``
- ``CastPlayer``
- ``CastRepeatMode``
- ``CastSettingsUpdate``
- ``CastSkip``

### Metadata

- <doc:metadata-article>
- <doc:optimization-article>

- ``CastCustomData``
- ``CastImage``
- ``CastImageHints``
- ``CastMetadata``

### Content Loading

- ``CastAsset``
- ``CastAssetURLConfiguration``
- ``CastLoadOptions``
- ``CastPlayerItem``

### User Interface

- <doc:user-interface-article>
- <doc:state-observation-article>

- ``CastButton``
- ``CastIcon``
- ``CastMiniPlayerView``
- ``CastMuteButton``
- ``CastPlayerView``
- ``CastProgressTracker``
- ``CastVolumeIcon``
- ``CastVolumeSlider``
