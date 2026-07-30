# Contributing guidelines

Thanks for your interest in **the-music-tree-blog**.

This repo is a solo practice project: a SPIP-based editorial blog for the TheMusicTree ecosystem. It follows **strict Git Flow**, matching the convention used in sibling repos such as [hear-the-music-tree-api](https://github.com/BehindTheMusicTree/hear-the-music-tree-api): semantic versioning via **`VERSION`**, **`CHANGELOG.md`**, and Git Flow branching.

## Table of contents

- [Development workflow](#development-workflow)
  - [Prerequisites](#prerequisites)
  - [Install and run](#install-and-run)
  - [Branching](#branching)
  - [Commits](#commits)
  - [Pull requests](#pull-requests)
- [Releasing](#releasing)

## Development workflow

### Prerequisites

- **Docker** and **Docker Compose**

### Install and run

```bash
./scripts/setup.sh   # clones SPIP core into web/, creates .env from .env.example
docker compose up -d
```

Open http://localhost:8080 and follow SPIP's install wizard using the DB credentials from `.env`.

### Branching

We follow **strict Git Flow**:

| Branch            | Role                                                              |
| ------------------ | ------------------------------------------------------------------ |
| `main`             | Production-ready, stable. Only receives merges from `release/*` and `hotfix/*`. Tagged for releases. |
| `develop`          | Integration branch. Receives merges from `feature/*`, `chore/*`, `dependabot/*`, `release/*`. |
| `feature/<name>`   | New functionality or template work. Branch from `develop`.       |
| `chore/<name>`     | Maintenance, tooling, config, docs. Branch from `develop`.        |
| `release/<version>`| Release prep (version bump, changelog). Branch from `develop`, merges into both `main` and `develop`. |
| `hotfix/<name>`    | Urgent production fixes. Branch from `main`, merges into both `main` and `develop`. |

No direct commits to `main` or `develop` — all changes go through pull requests.

```bash
git checkout develop
git pull origin develop
git checkout -b feature/sommaire-template
```

### Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

`<type>(<optional-scope>): <imperative summary>`

Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `style`, `ci`.

Examples: `feat(squelettes): add sommaire.html`, `fix(rubrique): correct article count query`, `chore: bump mariadb to 12.3`.

### Pull requests

Before opening a PR:

1. `docker compose up -d` starts cleanly and the change renders correctly at http://localhost:8080.
2. **`CHANGELOG.md`**: add bullets under **`[Unreleased]`**.
3. PR targets `develop` (features/chores) or `main` (hotfixes only).
4. PR title follows the same convention as commits.

## Releasing

1. Ensure `develop` is ready: all intended changes merged.
2. Branch: `git checkout -b release/vX.Y.Z` from `develop`.
3. Move `[Unreleased]` entries in `CHANGELOG.md` into a dated `## [X.Y.Z] - YYYY-MM-DD` section; set `VERSION` to `X.Y.Z` (no `v` prefix).
4. Merge the release branch into `main` (`--no-ff`), tag `vX.Y.Z`, push.
5. Merge the release branch back into `develop` to keep it current.
6. Delete the release branch.

**Hotfixes:** branch from `main` as `hotfix/<name>`, fix, update `CHANGELOG.md`, merge into both `main` (tag a patch bump) and `develop`.
