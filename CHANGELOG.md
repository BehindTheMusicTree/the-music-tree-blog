# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Changelog best practices

- Changelogs are for humans, not machines.
- Include an entry for every version, with the latest first.
- Group changes under: Added, Changed, Improved, Deprecated, Removed, Fixed, Documentation, CI.
- **"Test" is not a valid changelog category** — fold tests into the related feature or fix.
- Use an **Unreleased** section for upcoming changes.
- Use ISO 8601 dates: `2026-05-01`.
- Avoid raw git dumps; summarize clearly.

When you open a PR, add bullets under **`[Unreleased]`** in the right category. On release, move `[Unreleased]` content into a dated `## [x.y.z] - YYYY-MM-DD` section.

## [Unreleased]

### Added

- Scaffolded SPIP-based blog for the TheMusicTree ecosystem (Docker Compose stack, `squelettes/` for custom templates).
- Shared the `launch` skill between Claude and Codex, documenting SPIP setup, Docker Compose and the first-run install wizard.
