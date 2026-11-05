---
paths:
  - "**/*.swift"
---

# Swift code style

SwiftLint (`.swiftlint.yml`, strict mode) is the authority on formatting. Run `swiftlint --fix && swiftlint --quiet --strict` (or `make fix-quality`) after editing Swift files. The rules below cover conventions that the linter doesn't fully enforce, or that are easy to get wrong.

## Layout

- Indent with 4 spaces. Keep lines under 160 characters, and end files with a single newline (`.editorconfig`).
- Put `else` on its own line after a closing brace:

  ```swift
  if let beforeItem {
      …
  }
  else {
      prependItems(from: assets)
  }
  ```

- Single-statement guards stay on one line: `guard let self else { return }`.
- In multiline argument and parameter lists, put one element per line, the closing parenthesis on its own line, and a trailing comma on the last element (`trailing_comma: mandatory_comma`).
- Don't add `// MARK:` comments. Organize code with extensions instead.

## Organization

- One primary type per file, named after the type. Split large types into `Type+Feature.swift` files (`CastPlayer+Skip.swift`, `CastPlayer+Items.swift`).
- Put the public surface of a feature in a `public extension`, and its helpers in a `private extension` in the same file. Prefer `private static func` helpers over free functions.
- Declare protocol conformances in their own `extension Type: Protocol` blocks.
- Order type contents as SwiftLint's `type_contents_order` expects: static properties, then instance properties, then initializers, then methods. Declare internal helper types after the primary type in the file, or in their own file (`file_types_order`).
- Sort imports alphabetically. Don't keep unused imports (`make clean-imports`).

## Idioms

- Use implicit returns in single-expression functions, properties, and closures.
- Use `.init(…)` when the type is inferred (`= .init()`, `.init(value: options.shouldPlay)`), and `Self` in static references (`Self.rawItems(from:)`).
- Use shorthand optional binding (`if let item`, `guard let self`).
- Use key paths and shorthand arguments in single-line closures (`assets.map { $0.rawItem() }`). Name the arguments in multiline closures.
- Capture `[weak self]` in escaping closures stored by Google Cast objects or recipes, and never use `unowned`.
- Don't use force unwrapping or `try!` in library code. The only exception is values that can't fail, such as `URL(string:)!` with a constant string. Tests and samples may use them more freely.
- Use `Bool` rather than `Bool?`, and non-optional collections; avoid optional Booleans and optional collections.
- Keep functions small: cyclomatic complexity triggers a warning at 5. Extract helpers rather than nesting conditionals.
- Mark everything that touches Google Cast or UI state `@MainActor`. Conform to Google Cast Objective-C listener protocols with `@preconcurrency`.

## Tests

- Tests live in `Tests/CastorTests` and use Swift Testing, not XCTest. Write one `@Suite struct <Subject>Tests` per file, with `@Test` functions and `#expect` assertions. Import Castor with `@testable import Castor`.
- Test only logic that doesn't require a Cast receiver (value types, collection helpers, state conversions).
