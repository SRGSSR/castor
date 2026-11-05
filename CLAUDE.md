# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Castor is a Swift package (iOS 16+) that wraps the Google Cast SDK (`GoogleCast`) in an observable, SwiftUI-friendly API. A demo app lives in `Demo/` (`Castor-demo.xcodeproj`), using the package locally. The required Xcode version is pinned in `.xcode-version`.

## Commands

All `make` targets install their tools through `pkgx`/Bundler on first run.

- `make test`: runs the unit tests through fastlane (`bundle exec fastlane test`, scheme `Castor`, iPhone 16 simulator).
- `make build`: builds the demo app (`fastlane build_demo`).
- `make check-quality`: runs SwiftLint (`--strict`), RuboCop, shellcheck, markdownlint, and yamllint. `make fix-quality` autocorrects with `swiftlint --fix`.
- `make git-hook-install`: installs `hooks/pre-commit`, which runs `Scripts/public/check-quality.sh -c` (lints staged Swift files only).
- `make clean-imports` / `make find-dead-code`: maintenance utilities.

The fastlane lanes call `ensure_git_status_clean` before running and `reset_git_repo` afterwards, so `make test` and `make build` fail with uncommitted changes. To iterate without committing, call `xcodebuild` directly:

```bash
xcodebuild test -scheme Castor -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:CastorTests/CastResumeStateTests
```

`swift build` / `swift test` don't work: the package is iOS-only and depends on a binary GoogleCast framework.

## Architecture

`Cast` (`Sources/Castor/Cast/`) is the root `ObservableObject` an app creates and stores. It owns device discovery, sessions, and volume. When a session starts, it creates a `CastPlayer` (`Sources/Castor/Player/`) bound to the session's `GCKRemoteMediaClient`. `CastPlayer` features are split across `CastPlayer+<Feature>.swift` extensions. Apps receive session lifecycle events through `CastDelegate` and transfer playback between local and receiver playback through `Castable` and `CastResumeState`.

Receiver state is never stored locally as the source of truth. It is mirrored through a recipe and property wrapper pattern:

- **Recipes** (`Sources/Castor/Recipes/`) conform to `ReceiverStateRecipe`. A recipe subscribes to a Google Cast service (e.g. `GCKRemoteMediaClient`, `GCKSessionManager`) as a listener, extracts a `Status`, and maps it to an `Equatable` `Value`, with a `defaultValue` for when no status exists. `MutableReceiverStateRecipe` adds `requestUpdate(to:)`, which sends a request to the receiver and reports completion through `GCKRequestDelegate`.
- **Property wrappers** (`Sources/Castor/PropertyWrappers/`) use a recipe to expose that value on an `ObservableObject`. They forward changes to the enclosing instance's `objectWillChange`, and they're declared as `@ReceiverState` / `@MutableReceiverState`, initialized with `.init(service:recipe:)`. `@MutableReceiverState` updates its value optimistically while a request is in flight, ignores receiver updates until the request completes, and coalesces values set in the meantime into a single pending request.
- These wrappers use the `_enclosingInstance` subscript, so they only work in classes. Public properties are usually computed wrappers around the underscored storage (e.g. `@ReceiverState private var _devices` → `public var devices`).

To expose a new piece of receiver state, add a recipe and a wrapped property rather than caching values by hand. Everything here is `@MainActor`. Google Cast listener conformances use `@preconcurrency`.

`CastorPackageInfoPlugin` is a build tool plugin backed by a binary artifact in `Artifacts/`. It generates `PackageInfo` (used for `Cast.version`).

## Conventions

- SwiftLint runs in `--strict` mode with `missing_docs` enabled, so every public symbol needs a `///` comment. Publicly implemented protocol requirements (`==`, `hash(into:)`, Google Cast listener callbacks) use `// swiftlint:disable:next missing_docs` instead. Mandatory trailing commas and a 160-character line warning are also enforced.
- Documentation is a DocC catalog in `Sources/Castor/Castor.docc`. Every public type has an `Extensions/<kebab-name>-extension.md` topics file and is listed in `Castor.md` Topics. When you add or change public API, update both. The project skill `swift-docs` (`.claude/skills/swift-docs/`) holds the detailed documentation conventions.
- Swift files start with the SRG SSR copyright header used throughout `Sources/`.
