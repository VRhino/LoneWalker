#!/usr/bin/env bash
# LoneWalker — Railway initial setup
# Run from project root: bash scripts/setup-railway.sh
# Prerequisite: Railway CLI — npm i -g @railway/cli

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
step()    { echo ""; echo -e "${BOLD}── Step $1 ─────────────────────────────────────────────────${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"

# ── Prerequisites ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}LoneWalker — Railway Setup${NC}"
echo ""
command -v railway >/dev/null 2>&1 || die "Railway CLI not found.\n  Install with: npm i -g @railway/cli\n  Then re-run this script."
command -v openssl  >/dev/null 2>&1 || die "openssl not found. Install OpenSSL to generate JWT_SECRET."
info "Railway CLI: $(railway --version 2>/dev/null || echo 'found')"

# ── Step 1: Login ──────────────────────────────────────────────────────────────
step "1/6 — Login"
info "Opening browser for Railway authentication..."
railway login
ok "Authenticated."

# ── Step 2: Create / link project ─────────────────────────────────────────────
step "2/6 — Project"
echo "  Do you want to CREATE a new project or LINK to an existing one?"
echo "  [1] Create new project"
echo "  [2] Link to existing project"
read -rp "  Choice (1/2): " choice
case "$choice" in
  1)
    info "Creating new Railway project..."
    cd "$PROJECT_ROOT" && railway init
    ok "Project created."
    ;;
  2)
    info "Linking to existing Railway project..."
    cd "$PROJECT_ROOT" && railway link
    ok "Project linked."
    ;;
  *)
    die "Invalid choice."
    ;;
esac

# ── Step 3: Add PostgreSQL ─────────────────────────────────────────────────────
step "3/6 — PostgreSQL"
info "Adding PostgreSQL plugin..."
warn "In the interactive menu, select 'PostgreSQL'."
railway add --plugin postgresql
ok "PostgreSQL added."

# ── Step 4: Add Redis ──────────────────────────────────────────────────────────
step "4/6 — Redis"
info "Adding Redis plugin..."
warn "In the interactive menu, select 'Redis'."
railway add --plugin redis
ok "Redis added."

# ── Step 5: Environment variables ─────────────────────────────────────────────
step "5/6 — Environment variables"
info "Generating JWT_SECRET (openssl rand -hex 64)..."
JWT_SECRET=$(openssl rand -hex 64)
info "Setting variables on Railway..."

# Reference variables use Railway's ${{Plugin.VAR}} syntax — single quotes prevent shell expansion
railway variables set \
  NODE_ENV=production \
  JWT_SECRET="$JWT_SECRET" \
  JWT_EXPIRATION=3600 \
  REFRESH_TOKEN_EXPIRATION=604800 \
  DB_SYNCHRONIZE=true \
  DB_LOGGING=false \
  CORS_ORIGIN='*' \
  CORS_CREDENTIALS=true

# Reference variables — Railway resolves these at runtime
railway variables set 'DATABASE_URL=${{Postgres.DATABASE_URL}}'
railway variables set 'REDIS_URL=${{Redis.REDIS_URL}}'

ok "Variables set. DB_SYNCHRONIZE=true (disable once DB is stable)."

# ── Step 6: Deploy ─────────────────────────────────────────────────────────────
step "6/6 — Deploy"
info "Deploying backend from $BACKEND_DIR..."
cd "$BACKEND_DIR" && railway up
ok "Deployment triggered."

# ── Post-setup instructions ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Required manual step — enable PostGIS:${NC}"
echo ""
echo -e "    ${CYAN}make db-shell${NC}"
echo -e "    Then run:  ${YELLOW}CREATE EXTENSION IF NOT EXISTS postgis;${NC}"
echo -e "    Then exit: ${YELLOW}\\q${NC}"
echo ""
echo -e "  ${BOLD}After getting your Railway public domain, update CORS:${NC}"
echo ""
echo -e "    ${CYAN}railway variables set CORS_ORIGIN=https://YOUR_DOMAIN.up.railway.app${NC}"
echo ""
echo -e "  ${BOLD}Useful commands (see Makefile):${NC}"
echo "    make logs          — stream backend logs"
echo "    make status        — project overview"
echo "    make db-migrate    — run TypeORM migrations"
echo "    make deploy        — redeploy after changes"
echo ""
