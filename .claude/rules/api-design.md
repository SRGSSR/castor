---
paths:
  - "Sources/Castor/**/*.swift"
---

# Public API design

Castor's public API should feel like a native SwiftUI/AVFoundation API built on top of Google Cast, not a thin Google Cast wrapper. Follow the shape of existing APIs (`CastPlayer`, `Cast`, `CastAsset`) before inventing a new one.

## Types

- Prefix every public type with `Cast` (`CastPlayer`, `CastLoadOptions`, `CastSkip`). The only exception is `Castable`, a protocol.
- Use `@MainActor public final class … : ObservableObject` for stateful objects. Expose read-only state as `@Published public private(set) var`, or as computed properties over `@ReceiverState` storage (see `CLAUDE.md`).
- Use structs for configuration and value types (`CastConfiguration`, `CastLoadOptions`, `CastMetadata`). Provide a memberwise-style `public init` whose parameters have sensible defaults, so that `.init()` gives the standard behavior.
- Use enums for closed sets of choices. Prefer the `off`/`on(…)` naming (`CastMediaSelectionOption`, `CastMediaSelectionPreference`) and associated values (`.smart(interval:)`) over separate flag properties.
- Wrap Google Cast classes (`GCKMediaQueueItem`, `GCKMediaInformation`, …) in Castor types instead of exposing them. Convert with internal `init?(raw<Thing>:)` initializers and `raw<Thing>()` methods. Plain GCK enums and identifiers (`GCKConnectionState`, `GCKDeviceType`, `GCKMediaQueueItemID`) may be exposed directly when wrapping them adds nothing.
- Public members are protocol requirements, or live in a `public extension` organized by feature. Google Cast delegate and listener conformances that have to be public are marked `// swiftlint:disable:next missing_docs` and aren't part of the API surface.

## Methods and properties

- Use argument labels that read as English phrases in the Swift API Design Guidelines style: `loadItems(from:with:)`, `insertItem(from:after:)`, `move(_:before:)`, `mediaSelectionOptions(for:)`, `seek(to:)`, `startSession(with:)`.
- Pair every action that can be unavailable with a `can…` query: `canSkipForward()`/`skipForward()`, `canSeek(to:)`/`seek(to:)`, `canAdvanceToNextItem()`/`advanceToNextItem()`. The action must be safe to call when the query returns `false`, and then does nothing.
- Express values that depend on receiver state, or that are computed on demand, as methods (`time()`, `seekableTimeRange()`). Use properties for observable state (`state`, `items`, `playbackSpeed`).
- Invalid input is never a crash for API users:
  - Clamp values to a valid range (`playbackSpeed`, `CastLoadOptions.playbackSpeed`).
  - Ignore impossible requests (setting `currentDevice` to an unknown device, setting `volume` when it can't be adjusted).
  - Return `false` from mutations that can fail (`insertItem(from:after:)`, `move(_:before:)`) and mark them `@discardableResult`.
  - Reserve `assert` for programmer errors in configuration values (`CastConfiguration` skip intervals).
- An optional reference item means "the boundary": `nil` for `after:` inserts at the start, `nil` for `before:` appends at the end. Follow this convention for new queue APIs.
- Provide singular conveniences that forward to the plural version (`loadItem(from:with:)` → `loadItems(from:with:)`, `appendItem` → `appendItems`).
- Offer static factory methods for values with several construction forms (`CastAsset.entity(…)`, `.identifier(…)`, `.url(…)`). Add generic `Encodable` overloads next to the `CastCustomData?` ones when custom data is involved.

## SwiftUI integration

- Expose settable state that UI needs as a `Binding` (`mediaOption(for:) -> Binding<CastMediaSelectionOption>`) or as settable properties, so that it works with `$player.…` bindings.
- Ship ready-made menu content as `some View` builders meant to be wrapped in a `Menu` (`playbackSpeedMenu(speeds:action:)`, `standardSettingsMenu(…)`, `Cast.deviceMenu(action:)`). Take an optional `action` callback, with a `{ _ in }` default.
- Integrate with the app through `View` modifiers (`supportsCast(_:with:)`) rather than requiring subclasses or global state.
- Public views take their model (`cast:`, `deviceManager:`) as an initializer argument and observe it. They don't create their own `Cast` instance.

## Compatibility

- The package targets iOS 16. Don't use newer APIs without an availability check and a fallback.
- Treat public API changes as breaking unless they are purely additive. Prefer adding an overload or a defaulted parameter over changing an existing signature.
- Every public addition needs doc comments and a DocC catalog update (see the `swift-docs` skill).
