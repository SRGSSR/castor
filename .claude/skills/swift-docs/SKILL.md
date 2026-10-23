---
name: swift-docs
description: Write and maintain DocC documentation for the Castor Swift package — `///` doc comments on Swift symbols, Topics extension files in Castor.docc/Extensions, and conceptual articles in Castor.docc/Articles. Use this skill whenever the user asks to document, comment, explain in docs, write a DocC article or guide, add doc comments, fix SwiftLint missing_docs warnings, organize the documentation, or after adding/renaming public API in Sources/ — even if they don't say "DocC" explicitly.
---

# Swift documentation for Castor

Castor's public API is documented with DocC. Users of the package read it in Xcode Quick Help and on the generated documentation site, so docs should help someone *use* an API, not restate its signature. Consistency with the existing docs matters as much as correctness: new pages should read like they were written by the same author as `Sources/Castor/Castor.docc/Castor.md`.

The documentation lives in two places:

- **Source comments** (`///`) on symbols under `Sources/Castor/`.
- **The catalog** `Sources/Castor/Castor.docc/`:
  - `Castor.md` — landing page; its `## Topics` section lists every public top-level type.
  - `Extensions/<kebab-type-name>-extension.md` — one per public type, organizing its members into topic groups.
  - `Articles/` — conceptual articles (sometimes in a subfolder with card images).

## Workflow

Figure out which of these the user wants (often several), then follow the relevant section. Before writing anything, read 2–3 neighbouring files of the same kind so the tone and structure match — the conventions below are a summary, the existing files are the source of truth.

### 1. Doc comments

Read `references/comment-style.md` for the full conventions and examples. The essentials:

- Document every `public`/`open` symbol — SwiftLint's `missing_docs` rule enforces it. Internal symbols are documented only when their purpose isn't obvious from the name; don't blanket-comment internals the user didn't ask about.
- Start with a single-sentence summary that ends with a period, phrased the way the existing docs do it: types as noun phrases ("An observable object that manages…"), properties as noun phrases ("The current device."), methods as third-person verbs ("Fetches the complete information…"), initializers as "Creates <a noun>." ("Creates metadata.", "Creates loading options.", "Creates an instance."), Booleans as "A Boolean value indicating whether…".
- Add discussion paragraphs only when there's something worth saying: preconditions, side effects, behavior on edge cases (`nil`, empty, out of range), threading, how this relates to other APIs. Don't pad.
- Use `- Parameter name:` (single) or `- Parameters:` (multiple), and `- Returns:` for non-`Void` functions. Describe meaning, not type.
- Link other symbols with double backticks (` ``CastPlayer/play()`` `), code that isn't a symbol with single backticks.
- Protocol conformance requirements implemented publicly (`==`, `hash(into:)`, Google Cast listener callbacks) are marked `// swiftlint:disable:next missing_docs` rather than documented — keep that pattern.
- Never change code while documenting. If you notice a bug or a naming issue, mention it to the user instead.

### 2. Topics extension files

Every public type needs `Castor.docc/Extensions/<kebab-type-name>-extension.md` (e.g. `CastPlayerItem` → `cast-player-item-extension.md`) and an entry in the matching `### Group` under `## Topics` in `Castor.md`. Read `references/catalog.md` for the file format, grouping vocabulary and symbol-link disambiguation.

When adding or changing public members, update the type's extension file so the new member appears in the right group — members not listed fall into an auto-generated section, which looks unfinished.

### 3. Articles

Read `references/catalog.md` (Articles section) and at least one existing article before writing. Articles are task-oriented ("Control the pace at which content is played."), use `@Metadata { @PageColor(purple) }`, start with an abstract sentence and `## Overview`, then `###`/`##` sections with imperative headings ("Adjust the playback speed programmatically"). Link symbols generously, and link related articles with `<doc:article-id>`. Register a new article in `Castor.md` Topics (and `@Links` in Featured if it's a major topic — ask the user).

Article code samples should be realistic SwiftUI using Castor's actual API — check signatures in `Sources/` rather than guessing.

## Verifying

- If SwiftLint is available, `swiftlint lint --quiet --only-rule missing_docs` confirms that no public symbol is left undocumented.
- If Xcode is available, `xcodebuild docbuild -scheme Castor -destination generic/platform=iOS` resolves every link; warnings mentioning "doesn't exist" or "ambiguous" are broken or under-disambiguated links. It's slow (full build), so offer it rather than running it unasked for small changes.
- Markdown in the catalog is checked by `markdownlint` in `Scripts/public/check-quality.sh`; keep lines and headings tidy.

## Reporting back

Summarize what you documented (files and symbol counts), anything you deliberately skipped and why, and any questions — e.g. behavior you couldn't determine from the code. Guessing at behavior in published docs is worse than leaving a question for the user.
