#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$repo_root/web/index.php" ]; then
  echo "Cloning SPIP core (branch 4.4) into web/ ..."
  git clone --depth 1 --branch 4.4 https://git.spip.net/spip/spip.git "$repo_root/web"
else
  echo "web/ already contains SPIP core, skipping clone."
fi

if [ ! -f "$repo_root/web/vendor/autoload.php" ]; then
  echo "Installing SPIP core Composer dependencies ..."
  docker run --rm \
    -v "$repo_root/web:/app" \
    -w /app \
    composer:2 install --no-dev --optimize-autoloader
else
  echo "web/vendor already present, skipping composer install."
fi

if [ ! -f "$repo_root/.env" ]; then
  cp "$repo_root/.env.example" "$repo_root/.env"
  echo "Created .env from .env.example — edit it before starting the stack."
fi
