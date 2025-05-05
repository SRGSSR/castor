# Known issues

This document lists known issues affecting Castor:

- Entries with a feedback number (`FBxxxxxxxx`) have been reported to Apple and are pending resolution in future iOS updates.
- Issues with a numeric identifier have been filed on the [Google Cast issue tracker](https://issuetracker.google.com/issues?q=componentid:190205%20status:open&s=modified_time:desc) and may be addressed in upcoming Google Cast SDK updates.

## Incorrect time ranges and progress reporting for HLS live DVR streams ([397112872](https://issuetracker.google.com/issues/397112872))

HLS live DVR streams report incorrect time ranges, which in turn causes inaccurate progress reporting for these streams.

### Workaround

No workaround is available yet.

## Items not updated during scrolling ([415626993](https://issuetracker.google.com/issues/415626993))

When calling `CastPlayerItem.fetch()` to lazily load metadata for items in a scrollable view, updates are not delivered until scrolling stops.

Additionally, scrolling for an extended period during metadata fetching may cause the cast session to be suspended.

### Workaround

No workaround is available yet.

## Removing the current item multiple times may stop the cast session ([412384508](https://issuetracker.google.com/issues/412384508))

Each time the current item is removed, the receiver advances to the next item in the queue. Removing the current item several times consecutively can therefore cause the player to switch items repeatedly, potentially resulting in the cast session being stopped.

### Workaround

No workaround is available yet.

## Metadata fetch limited to 20 visible items ([412384508](https://issuetracker.google.com/issues/412384508))

The Google Cast SDK limits metadata requests to a maximum of 20 visible `CastPlayerItem`s at a time. In scenarios such as displaying a list with more than 20 visible items, some entries may be unable to fetch their associated metadata.

### Workaround

No workaround is available yet.
