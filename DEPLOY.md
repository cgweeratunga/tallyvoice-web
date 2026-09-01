# Deploying tallyvoice.ai

This site has **no deploy script, no CI and no build step**. It is plain static
HTML pushed to a droplet by hand. That is why this file exists: the rsync
exclude list below is the only record of what must not reach the server, and an
ad-hoc command typed from memory will not have it.

**If you ever add a deploy script, move the exclude list into it and delete this
warning — do not leave two copies to drift apart.**

## What must never be deployed

| Path | Why |
|---|---|
| `privacy/NOTES.md` | Working engineering record for the privacy policy. Contains open security items, unshipped work and internal reasoning. |
| `terms/NOTES.md` | Same, for the terms of service. |
| `DEPLOY.md` | This file. Names the server and the deploy mechanics. |
| `README.md` | Internal notes, unshipped plans. |
| `.git/`, `.gitignore` | Repository metadata. Publishing `.git/` exposes full history. |

### Why this matters — it has already gone wrong once

Both legal pages originally carried their working notes in an HTML comment at
the top of `index.html`. Being a comment, it deployed with the page and was
publicly readable with view-source on the live site. What was exposed:

- `/privacy/` — the category headings `BLOCKING - no delete-account route
  exists` and `BLOCKING - infrastructure`, on the very page that tells users how
  deletion works; plus an open item recording that QuickBooks OAuth tokens are
  stored in plaintext.
- `/terms/` — the paragraph recording that the homepage pricing tiers are
  placeholder copy and that nobody has paid for anything. `/terms/` is a URL
  submitted to Intuit.

The notes now live in `NOTES.md` beside each page and are excluded below. Each
`index.html` keeps a one-line comment pointing at its `NOTES.md`.

Two things follow from the pages having already shipped with the comments:

1. **The leak is not closed until this change is deployed.** Until then, both
   live pages still expose their full block.
2. The old markup may persist in caches, crawlers and archive services. Removing
   it from the server does not retract what has already been fetched. Treat
   anything that was in those blocks as having been public since 1 Sep 2026.

## The deploy

The marketing site and the Django backend are **different droplets**:

| Host | IP | What it serves |
|---|---|---|
| `tallyvoice.ai` | `170.64.175.204` | this repo, from `/var/www/tallyvoice` |
| `app.tallyvoice.ai` | `170.64.233.156` | the Django app (`pulsebooks`) |

> **The SSH aliases are a trap.** Every `tallyvoice_*` entry in `~/.ssh/config`
> points at `170.64.233.156`, the backend. There is no alias for the marketing
> droplet. Use the IP, and run the sanity check below before writing anything.

```bash
# ── 0. Set once, and confirm the host is the MARKETING droplet ──────────────
SITE=/home/chinthaka/www/dilanthaf/tallyvoice-web
HOST=root@170.64.175.204          # tallyvoice.ai — NOT 170.64.233.156
STAMP=$(date +%Y%m%d-%H%M%S)

# Must print the marketing site's title. If it prints anything Django-shaped,
# stop — you are pointed at the wrong droplet.
ssh $HOST 'head -c 400 /var/www/tallyvoice/index.html | grep -o "<title>.*</title>"'

# ── 1. Back up what is live, before anything is written ─────────────────────
ssh $HOST "tar -czf /root/tallyvoice-backup-$STAMP.tar.gz -C /var/www tallyvoice \
           && ls -lh /root/tallyvoice-backup-$STAMP.tar.gz"

# ── 2. DRY RUN with --delete. Read this output before going further. ────────
#    Any 'deleting ...' line means the droplet holds a file this repo does not.
#    Stop and find out what it is before proceeding.
rsync -avzn --delete \
  --exclude '.git' --exclude '.gitignore' \
  --exclude 'README.md' --exclude 'DEPLOY.md' --exclude 'NOTES.md' \
  "$SITE/" "$HOST:/tmp/tallyvoice-stage-$STAMP/"

# ── 3. Stage to /tmp for real (still not live) ──────────────────────────────
rsync -avz --delete \
  --exclude '.git' --exclude '.gitignore' \
  --exclude 'README.md' --exclude 'DEPLOY.md' --exclude 'NOTES.md' \
  "$SITE/" "$HOST:/tmp/tallyvoice-stage-$STAMP/"

# ── 4. VERIFY THE STAGED COPY. Do not skip this. ────────────────────────────
#    No NOTES.md may have been staged, and no page may contain working-note
#    text. Both commands must report zero.
ssh $HOST "find /tmp/tallyvoice-stage-$STAMP -name 'NOTES.md' -o -name 'DEPLOY.md' -o -name 'README.md' | wc -l"
ssh $HOST "grep -rl 'BLOCKING\|BEFORE-PUBLISH\|BEFORE-LAUNCH\|UNCONFIRMED' /tmp/tallyvoice-stage-$STAMP/ | wc -l"

ssh $HOST "grep -o '<title>.*</title>' /tmp/tallyvoice-stage-$STAMP/terms/index.html; \
           grep -o 'Last updated <strong>[^<]*' /tmp/tallyvoice-stage-$STAMP/terms/index.html"

# ── 5. Move into place (atomic swap per directory) ──────────────────────────
ssh $HOST "cd /tmp/tallyvoice-stage-$STAMP \
  && cp -a privacy /var/www/tallyvoice/privacy.new && mv /var/www/tallyvoice/privacy.new /var/www/tallyvoice/privacy \
  && cp -a terms   /var/www/tallyvoice/terms.new   && mv /var/www/tallyvoice/terms.new   /var/www/tallyvoice/terms \
  && cp -a index.html styles.css legal.css script.js favicon.svg /var/www/tallyvoice/ \
  && chown -R www-data:www-data /var/www/tallyvoice \
  && ls -la /var/www/tallyvoice/"

# ── 6. Verify live ──────────────────────────────────────────────────────────
for p in / /privacy/ /terms/; do
  echo -n "$p "; curl -sS -o /dev/null -w '%{http_code}\n' "https://tallyvoice.ai$p"
done
# These must return NOTHING. If either prints a line, the leak is still live.
curl -sS https://tallyvoice.ai/privacy/ | grep -n 'BLOCKING\|BEFORE-PUBLISH\|UNCONFIRMED'
curl -sS https://tallyvoice.ai/terms/   | grep -n 'BLOCKING\|BEFORE-PUBLISH\|UNCONFIRMED'
# These must 404, not 200.
for p in /privacy/NOTES.md /terms/NOTES.md /DEPLOY.md /README.md; do
  echo -n "$p "; curl -sS -o /dev/null -w '%{http_code}\n' "https://tallyvoice.ai$p"
done

# ── Rollback ────────────────────────────────────────────────────────────────
# ssh $HOST "tar -xzf /root/tallyvoice-backup-$STAMP.tar.gz -C /var/www"
```

## Note on URLs without a trailing slash

nginx on this droplet serves `index.html` with a **200** for every unmatched
path, so a wrong URL does not 404 — it silently returns the homepage. `/privacy/`
and `/terms/` (with the slash) resolve correctly. Whether `/privacy` and `/terms`
resolve depends on whether the `try_files` chain includes `$uri.html`, which has
not been read on the server. Check both forms after any deploy, and if the
slashless form serves the homepage, fix the nginx config rather than adding
duplicate files.
