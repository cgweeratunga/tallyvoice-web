#!/usr/bin/env bash
# Deploy tallyvoice.ai (static site) to the marketing droplet.
#
#   ./deploy.sh          preview only: shows what would change, touches nothing
#   ./deploy.sh --go     back up the server, then deploy
#
# The server is reached through an SSH alias so no address lives in this repo.
# Add to ~/.ssh/config (NOT committed anywhere):
#
#   Host tallyvoice-web
#       HostName <marketing droplet IP - not the app.tallyvoice.ai one>
#       User root
#
# Override with:  TALLYVOICE_HOST=otheralias ./deploy.sh
set -euo pipefail

HOST="${TALLYVOICE_HOST:-tallyvoice-web}"
REMOTE_DIR=/var/www/tallyvoice
SITE_URL=https://tallyvoice.ai

# Allowlist: the only files that are ever published. Anything not listed here
# (notes, README, this script, .git) cannot reach the server.
FILES=(
  index.html
  styles.css
  legal.css
  script.js
  favicon.svg
  privacy/index.html
  terms/index.html
)

GO=0
[[ "${1:-}" == "--go" ]] && GO=1

cd "$(dirname "$0")"

# ── 1. Only deploy committed, pushed code ────────────────────────────────────
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or stash first." >&2; exit 1
fi
git fetch -q origin
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]]; then
  echo "HEAD is not the same as origin. Push (or pull) first." >&2; exit 1
fi
REV=$(git rev-parse --short HEAD)

# ── 2. Build the release from HEAD, allowlisted files only ───────────────────
BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT
git archive HEAD "${FILES[@]}" | tar -x -C "$BUILD"

if grep -rlE 'BLOCKING|BEFORE-PUBLISH|BEFORE-LAUNCH|UNCONFIRMED' "$BUILD"; then
  echo "Working-note markers found in the files above. Not deploying." >&2; exit 1
fi

# ── 3. Make sure we are talking to the marketing droplet, not the app ────────
TITLE=$(ssh "$HOST" "grep -o '<title>.*</title>' $REMOTE_DIR/index.html" || true)
if [[ "$TITLE" != *TallyVoice* ]]; then
  echo "Host '$HOST' does not look like the marketing site (title: '$TITLE'). Stopping." >&2
  exit 1
fi
echo "Target: $HOST:$REMOTE_DIR  ($TITLE)"
echo "Release: $REV"
echo

# ── 4. Preview ───────────────────────────────────────────────────────────────
RSYNC=(rsync -rlptvzc --chmod=D755,F644 --chown=www-data:www-data --delay-updates)
"${RSYNC[@]}" -n "$BUILD/" "$HOST:$REMOTE_DIR/"

if [[ $GO -eq 0 ]]; then
  echo
  echo "Preview only. Nothing was changed. Run './deploy.sh --go' to deploy."
  exit 0
fi

read -r -p "Deploy $REV to $SITE_URL? [y/N] " ok
[[ "$ok" == y || "$ok" == Y ]] || { echo "Cancelled."; exit 1; }

# ── 5. Back up, then deploy ──────────────────────────────────────────────────
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP=/root/tallyvoice-backup-$STAMP.tar.gz
ssh "$HOST" "tar -czf $BACKUP -C /var/www tallyvoice && ls -lh $BACKUP"

"${RSYNC[@]}" "$BUILD/" "$HOST:$REMOTE_DIR/"

# ── 6. Verify live ───────────────────────────────────────────────────────────
echo
fail=0
for p in / /privacy/ /terms/; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' "$SITE_URL$p")
  echo "$p $code"; [[ "$code" == 200 ]] || fail=1
done
for p in /privacy/NOTES.md /terms/NOTES.md /README.md /deploy.sh /.git/HEAD; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' "$SITE_URL$p")
  echo "$p $code (must not be 200)"; [[ "$code" != 200 ]] || fail=1
done

if [[ $fail -ne 0 ]]; then
  echo
  echo "VERIFY FAILED. Roll back with:" >&2
  echo "  ssh $HOST 'tar -xzf $BACKUP -C /var/www'" >&2
  exit 1
fi
echo
echo "Deployed $REV. Backup on server: $BACKUP"
echo "Rollback: ssh $HOST 'tar -xzf $BACKUP -C /var/www'"
