# The Music Tree — Blog

Editorial blog for the [TheMusicTree](https://themusictree.org) ecosystem: project updates, artist spotlights, and genre deep-dives. Built with [SPIP](https://www.spip.net/), a French open-source editorial CMS, as a hands-on way to practice SPIP's core concepts (articles, rubriques, multi-author publishing, RSS) outside the rest of the Next.js/Django-based ecosystem.

## Stack

- [SPIP](https://www.spip.net/) 4.4 (PHP)
- MariaDB
- Docker Compose

## Setup

```bash
./scripts/setup.sh   # clones SPIP core into web/, creates .env from .env.example
docker compose up -d
```

Then open http://localhost:8080 and follow SPIP's install wizard, using the DB credentials from `.env`.

## Structure

- `web/` — SPIP core (vendored via `scripts/setup.sh`, not tracked in git)
- `squelettes/` — custom templates (mounted over `web/squelettes/`), where all the practice work happens

## Practice roadmap

- [ ] `sommaire.html` — homepage listing recent articles
- [ ] `article.html` — single article template
- [ ] `rubrique.html` — section/category template
- [ ] Multi-author bylines
- [ ] RSS feed (`backend.html` / native syndication)
- [ ] Mots-clés (keywords) for tagging articles by genre/topic
