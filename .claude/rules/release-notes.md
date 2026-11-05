# Release notes

Castor releases are published on GitHub (https://github.com/SRGSSR/castor/releases). The tag is a plain semantic version with no `v` prefix (`3.0.1`). Draft release notes in this format, modeled on releases 2.0.0 to 3.0.1.

## Gathering changes

- Find the previous tag with `git describe --tags --abbrev=0`. List merged PRs since then with `git log --oneline <previous>..HEAD`, or `gh pr list --state merged --base main --search "merged:>=<date of previous tag>"`.
- Generate the "What's Changed" part instead of writing it by hand: `gh api repos/SRGSSR/castor/releases/generate-notes -f tag_name=<new> -f previous_tag_name=<previous> --jq .body`.
- Read the PR descriptions and diffs of user-facing changes. Don't rely on PR titles alone, because the curated sections explain impact, not just what was done.

## Version number

Pick the bump from the curated content:
- **Major**: any breaking change to public API or behavior (3.0.0 added `@MainActor` to the public protocols).
- **Minor**: new features or capabilities.
- **Patch**: fixes and small additive refinements (3.0.1 added an optional parameter with a default value).

Propose a version and say why; the maintainers decide.

## Structure

```markdown
<One-sentence summary starting with "This release …">

## Breaking Changes

- …

## Improvements

- …

## Fixes

- …

## Dependency Updates

- …

## Toolchain Updates

- …

## What's Changed

<GitHub-generated list, verbatim>

**Full Changelog**: https://github.com/SRGSSR/castor/compare/<previous>...<new>
```

- **Title**: a short sentence-case phrase naming the release's main theme, with no trailing period ("Improve Swift Concurrency support", "Support paired devices", "Improve Cast view color customization"). A patch release that only contains fixes is titled "Maintenance release".
- **Summary**: a single sentence, for example "This release improves Swift Concurrency support." or, for maintenance releases, "This release addresses stability issues."
- **Sections**:
  - Include only the sections that have content, in the order shown above.
  - Always use plural headings ("Breaking Changes", "Dependency Updates"). Some older releases used the singular; don't copy that.
  - Keep "What's Changed" and the "Full Changelog" link at the end, exactly as GitHub generates them, including any "New Contributors" section.

## Writing entries

- Start each bullet with a past-tense verb ("Added", "Fixed", "Made", "Marked", "Removed"), as in recent releases. End it with a period.
- Write from the point of view of an app integrating Castor: what changed for them and why it matters. Name APIs in backticks, with their type (`CastButton`, `Castable`, `CastPlayer.returnToPreviousItem()`).
  - Good: "Made `CastDevice` and `CastPlayerItem` conform to `Identifiable` for more ergonomic integration with `List`."
  - Bad: "Make some types conforming to Identifiable (#289)."
- **Breaking Changes**: say what changed and what apps must do to migrate (the replacement API, or the annotation they need to add). List every removed or renamed public symbol.
- **Fixes**: describe the symptom that apps saw ("Fixed crash sometimes occurring when devices are updated."), not the internal cause.
- **Dependency Updates**: list only dependencies that affect apps, mainly the Google Cast SDK ("Updated Google Cast SDK to version `4.8.4`.").
- **Toolchain Updates**: list changes to the minimum Swift, Xcode or iOS versions that apps need.
- One bullet can cover several related PRs. Don't repeat the same change in two sections.

## Leave out of the curated sections

These still appear in the generated "What's Changed" list:
- Dependabot bumps of build tooling (fastlane, Ruby gems, GitHub Actions) and of package dependencies that don't change behavior.
- CI, linting, scripts, Xcode version used by CI, and screenshot updates.
- Changes that only affect the demo app. Mention them only in a "Demo Improvements" section when they're substantial (0.3.0 had one).
- Documentation-only changes, unless a release is mainly about documentation (1.0.0 mentioned the new DocC catalog).

## Publishing

Produce the Markdown and title for review. Don't create or edit a GitHub release, or push a tag, unless asked explicitly. When asked, create it as a draft: `gh release create <new> --draft --title "<title>" --notes-file <file>`.
