# ``Castor/CastPlayer``

## Topics

### Managing Player Items

- ``appendItem(from:)``
- ``appendItems(from:)``
- ``insertItem(from:after:)``
- ``insertItem(from:before:)``
- ``insertItems(from:after:)``
- ``insertItems(from:before:)``
- ``loadItem(from:with:)``
- ``loadItems(from:with:)``
- ``move(_:after:)``
- ``move(_:before:)``
- ``prependItem(from:)``
- ``prependItems(from:)``
- ``remove(_:)``
- ``removeAllItems()``

### Controlling Playback

- ``pause()``
- ``play()``
- ``stop()``
- ``togglePlayPause()``

### Observing Playback Properties

- ``currentAsset``
- ``state``
- ``time()``

### Seeking Through Media

- ``canSeek(to:)``
- ``seek(to:)``
- ``seekableTimeRange()``

### Skipping Through Media

- ``canSkip(_:)``
- ``canSkipBackward()``
- ``canSkipForward()``
- ``canSkipToDefault()``
- ``skip(_:)``
- ``skipBackward()``
- ``skipForward()``
- ``skipToDefault()``

### Navigating Between Items

- ``advanceToNextItem()``
- ``canAdvanceToNextItem()``
- ``canReturnToPreviousItem()``
- ``currentItem``
- ``returnToPreviousItem()``

### Managing Media Selection

- ``currentMediaOption(for:)``
- ``mediaOption(for:)``
- ``mediaSelectionCharacteristics``
- ``mediaSelectionOptions(for:)``
- ``select(mediaOption:for:)``
- ``selectedMediaOption(for:)``
- ``setMediaSelectionPreference(_:for:)``

### Controlling Playback Speed

- ``playbackSpeed``
- ``playbackSpeedRange``

### Integrating with SwiftUI Menus

- ``mediaSelectionMenu(characteristic:action:)``
- ``playbackSpeedMenu(speeds:action:)``
- ``standardSettingsMenu(speeds:action:)``
