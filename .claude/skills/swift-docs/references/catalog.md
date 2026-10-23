# The Castor.docc catalog

## Layout

```
Sources/Castor/Castor.docc/
├── Castor.md                     # landing page + top-level Topics
├── Extensions/                   # one <kebab-type>-extension.md per public type
└── Articles/
    ├── playback-speed-article.md # simple article
    └── playback/                 # article with resources
        ├── playback-article.md
        └── playback-card.jpg
```

## Extension files

File name: the type name in kebab case followed by `-extension.md` (`CastMediaSelectionOption` → `cast-media-selection-option-extension.md`). Contents:

```markdown
# ``Castor/CastPlayerItem``

## Topics

### Reading Information

- ``asset``
- ``id``

### Fetching Data

- ``fetch()``
- ``isFetched``
```

- The title is ``Castor/<TypeName>``. Nested types use ``Castor/Outer/Inner``.
- Members are linked relative to the type (no type prefix).
- Group headings are Title Case gerund phrases. Reuse the vocabulary already in the catalog before you make up a new heading (`grep -h "^### " Extensions/*.md | sort | uniq -c` lists it). Common ones: "Creating a <Type>", "Reading Information", "Getting Device Information", "Managing …", "Handling … Events", "Comparing <Plural>" (for `==(_:_:)`), and "Getting the Body" (for a SwiftUI view's ``body``).
- Order groups from most to least commonly used. Initializers and factory methods usually come first.
- List every public member, including `body` for views and `==(_:_:)` when it's meaningful to compare instances. Leave out `hash(into:)`. Members that aren't listed end up in DocC's auto-generated sections.
- Read 2–3 existing extension files of similar types before you write one.

## Castor.md Topics

`## Topics` contains `### <Area>` groups. Each group lists related articles first (`- <doc:...>`), then a blank line, then the types (``` - ``Type`` ```), alphabetically. When you add a public type, put it in the group that matches its area. If no group fits, ask the user rather than creating one.

## Articles

```markdown
# Playback Speed

@Metadata {
    @PageColor(purple)
}

Control the pace at which content is played.

## Overview

<1–2 paragraphs: why the reader cares, which main type is involved>

### Adjust the playback speed programmatically

<explanation linking ``CastPlayer/playbackSpeed`` and other relevant symbols>

### Provide speed controls

...
```

- The file name is `<topic>-article.md`, and the article is referenced as `<doc:<topic>-article>`.
- The title is Title Case. The abstract is a single imperative sentence.
- Section headings are sentence case and imperative ("Load content", "Provide speed controls").
- Featured articles have a card image: `@PageImage(purpose: card, source: <name>-card, alt: "...")`, with the image in the article's subfolder. Ask the user for the image; don't invent one.
- Use `> Tip:`, `> Important:` and `> Note:` asides, `@TabNavigator`, and fenced `swift` code blocks where they help.
- Code samples must compile against the current API. Check every symbol you use in `Sources/`.
- Register the article in `Castor.md` under the matching Topics group.

## Symbol link disambiguation

When a symbol is overloaded, a plain link is ambiguous and DocC emits a warning. The repo uses two styles:

- Type-signature disambiguation (preferred, readable): ``` ``SwiftUICore/View/supportsCast(_:with:)-(_,CastDelegate)`` ```, ``` ``url(_:configuration:metadata:customData:)-(_,_,_,T)`` ```
- Hash suffix (legacy; avoid in new docs): ``` ``CastAsset/url(_:configuration:metadata:customData:)-6xskn`` ```

Extensions on SwiftUI's `View` are linked through `SwiftUICore/View/...`.
