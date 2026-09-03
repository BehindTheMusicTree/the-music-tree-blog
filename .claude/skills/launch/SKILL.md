---
name: launch
description: Use this skill when asked to run, start, or preview the-music-tree-blog. Covers the SPIP vendoring step, Docker Compose services, and the manual install-wizard step SPIP requires on first run.
---

# Launch the-music-tree-blog

SPIP (PHP CMS) + MariaDB, run via Docker Compose. First run needs an extra
manual step through SPIP's own install wizard — there is no fully headless
first-run command.

## 1. First-time setup

```bash
./scripts/setup.sh   # clones SPIP core into web/ (untracked) and creates .env from .env.example
```

`web/` is not tracked in git — `setup.sh` must be re-run after a fresh clone
or if `web/` is missing/empty.

## 2. Start the stack

```bash
docker compose up -d
```

Starts `db` (MariaDB) and `spip` (Apache + SPIP), spip published on
`localhost:8080`.

## 3. First run only — SPIP install wizard

Open http://localhost:8080 and complete SPIP's install wizard using the DB
credentials from `.env` (`DB_NAME`/`DB_USER`/`DB_PASSWORD`). Subsequent
`docker compose up -d` runs skip this — SPIP is already installed once the
wizard has completed and its config is persisted in the `db_data` volume.

## 4. Verify

`docker compose ps` should show both `db` and `spip` running; the blog
should be reachable at http://localhost:8080.
