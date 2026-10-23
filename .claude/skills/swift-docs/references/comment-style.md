# Doc comment style

These examples are taken from (or modeled on) `Sources/Castor/`. When in doubt, grep for a similar symbol and copy its shape.

## Types

Summary noun phrase, then a short discussion explaining the role of the type and how to obtain or use it. Link to the APIs a reader needs next.

```swift
/// An observable object that manages all aspects of Google Cast.
///
/// `Cast` is a top-level type responsible for handling available devices, active sessions, and the volume of the
/// current device.
///
/// Once a session is established, use ``Cast/player`` to load content and control playback.
@MainActor
public final class Cast: NSObject, ObservableObject {
```

Inside its own type's comment, the type name is written with single backticks (`` `Cast` ``); other types are linked with double backticks.

## Properties

Noun phrase. Add a sentence when setting has side effects, when a value can be `nil` and why, or when there's a precondition.

```swift
/// The current device.
///
/// Does nothing if set to `nil` or to a device that does not belong to ``Cast/devices``.
public var currentDevice: CastDevice? {
```

```swift
/// A Boolean value indicating whether progress information is available.
public var isProgressAvailable: Bool {
```

Use "A Boolean value indicating whether…" for `Bool` properties (a few older comments say "that indicates whether" — prefer "indicating").

## Methods

Third-person verb summary. `- Parameter` for one parameter, `- Parameters:` with an indented list for several, `- Returns:` whenever the return type isn't `Void`. For `Bool` returns use the form "`true` if …; otherwise, `false`."

```swift
/// Checks whether the player is currently casting to a given device.
///
/// - Parameter device: The device to check.
/// - Returns: `true` if the device is casting; otherwise, `false`.
public func isCasting(on device: CastDevice) -> Bool {
```

```swift
/// Decodes the custom data.
///
/// - Parameters:
///   - type: The type to decode.
///   - decoder: The decoder to use.
/// - Returns: The decoded value, or `nil` if decoding fails.
public func decoded<T>(as type: T.Type, using decoder: JSONDecoder = .init()) -> T? where T: Decodable {
```

## Initializers

"Creates <noun>." followed by parameters. Behavioral discussion (e.g. failure conditions of a failable initializer) can come after the parameter list — both orders exist in the codebase; follow the file you're in.

```swift
/// Creates a state.
///
/// - Parameters:
///   - assets: The assets in the queue.
///   - options: The options to use when resuming playback.
///
/// Fails if the provided index is not valid for the asset list.
public init?(assets: [CastAsset], options: CastLoadOptions) {
```

## Enum cases

Short noun phrase or sentence per case.

## SwiftUI views and modifiers

Describe what the view displays and how it behaves, and say what the caller has to provide (bindings, environment, a player). For modifiers, describe the effect on the modified view.

## Asides

Use DocC asides sparingly, one idea each:

```swift
/// > Note: The media selection preference applies only to the first content played in a session.
/// > Important: Keep the payload size small to avoid exceeding the [maximum transport message size](https://developers.google.com/cast/docs/media/messages).
/// > Warning: Adjust the icon size using ``font(_:)``.
```

## Links

- ``Type``, ``Type/member``, ``Type/method(_:label:)`` — include argument labels for methods.
- Overloads need disambiguation; see `catalog.md`.
- External Apple types: link to developer.apple.com with Markdown, e.g. [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject).
- Google Cast SDK concepts: link to developers.google.com/cast when a reader needs background.

## Writing tips

- Lines wrap below 160 characters (SwiftLint `line_length` warning).
- Explain *what the caller gets and when to use it*; don't restate the signature ("The `foo` parameter of type `Int`").
- Mention units (seconds, `CMTime`), ranges, and defaults when they matter.
- Use American English and the Oxford comma, as in the existing docs.
- Don't document behavior you inferred but couldn't confirm in the code. Ask the user instead.
