# Project guidance

The Music Tree Blog is a SPIP/PHP editorial site backed by MariaDB. The SPIP
core is vendored into `web/` by `scripts/setup.sh`; project templates live in
`squelettes/`. Read `README.md` for setup, `CONTRIBUTING.md` for Gitflow and
`DEPLOYMENT.md` for deployment.

Feature and chore branches target `develop`; release and hotfix branches target
`main` and must be integrated back into `develop`. Update `CHANGELOG.md` for
changes. Use `.agents/skills/launch/SKILL.md` for local startup; Claude uses the
same skill via `.claude/skills/launch`.
