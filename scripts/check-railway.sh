#!/usr/bin/env bash
# LoneWalker — Railway health check
# Usage: bash scripts/check-railway.sh

set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

PASS=0; WARN=0; FAIL=0

ok()      { echo -e "  ${GREEN}✔${NC}  $*"; PASS=$((PASS+1)); }
warn()    { echo -e "  ${YELLOW}⚠${NC}  $*"; WARN=$((WARN+1)); }
fail()    { echo -e "  ${RED}✘${NC}  $*"; FAIL=$((FAIL+1)); }
info()    { echo -e "  ${DIM}→${NC}  $*"; }
section() { echo ""; echo -e "${BOLD}$*${NC}"; }

# JSON helper: reads JSON from stdin via node (works on Windows)
njq() {
  local json="$1"
  local expr="$2"
  echo "$json" | node -e "let s='';process.stdin.on('data',c=>s+=c);process.stdin.on('end',()=>{try{const d=JSON.parse(s);const r=($expr);process.stdout.write(r===undefined||r===null?'':String(r));}catch(e){process.stdout.write('');}})" 2>/dev/null || echo ""
}

# ── Prerequisite ───────────────────────────────────────────────────────────────
command -v railway >/dev/null 2>&1 || { echo -e "${RED}Railway CLI not found.${NC}"; exit 1; }
command -v node    >/dev/null 2>&1 || { echo -e "${RED}node not found.${NC}"; exit 1; }

echo ""
echo -e "${BOLD}LoneWalker — Railway status check${NC}"
echo -e "${DIM}$(date)${NC}"

# ── 1. Project link ────────────────────────────────────────────────────────────
section "1. Project"
STATUS_JSON=$(railway status --json 2>/dev/null) || { fail "Not linked to a Railway project. Run: railway link"; exit 1; }
PROJECT_NAME=$(njq "$STATUS_JSON" "d.name")
ok "Linked to project: ${CYAN}$PROJECT_NAME${NC}"

# ── 2. Services ────────────────────────────────────────────────────────────────
section "2. Services"

svc_status() {
  local name="$1"
  njq "$STATUS_JSON" "
    (function(){
      var envs=((d.environments||{}).edges)||[];
      if(!envs.length) return 'MISSING';
      var instances=((envs[0].node.serviceInstances||{}).edges)||[];
      var svc=instances.find(function(i){return i.node.serviceName==='$name';});
      if(!svc) return 'MISSING';
      var dep=svc.node.latestDeployment;
      return dep ? dep.status : 'NOT_DEPLOYED';
    })()
  "
}

POSTGRES_STATUS=$(svc_status "postgres")
REDIS_STATUS=$(svc_status "Redis")
BACKEND_STATUS=$(svc_status "backend")

check_service() {
  local label="$1" status="$2"
  case "$status" in
    SUCCESS)      ok "$label: ${GREEN}RUNNING${NC}" ;;
    BUILDING)     warn "$label: ${YELLOW}BUILDING${NC} (deploy in progress)" ;;
    DEPLOYING)    warn "$label: ${YELLOW}DEPLOYING${NC} (deploy in progress)" ;;
    FAILED)       fail "$label: ${RED}FAILED${NC}" ;;
    NOT_DEPLOYED) warn "$label: not yet deployed" ;;
    MISSING)      fail "$label: not found in project" ;;
    *)            warn "$label: ${status:-unknown}" ;;
  esac
}

check_service "postgres" "$POSTGRES_STATUS"
check_service "Redis"    "$REDIS_STATUS"
check_service "backend"  "$BACKEND_STATUS"

# ── 3. Environment variables ───────────────────────────────────────────────────
section "3. Environment variables (backend service)"

VARS_JSON=$(railway variables --json --service backend 2>/dev/null) || VARS_JSON="{}"

required_vars=(
  NODE_ENV
  JWT_SECRET
  JWT_EXPIRATION
  REFRESH_TOKEN_EXPIRATION
  DATABASE_URL
  REDIS_URL
  DB_SYNCHRONIZE
  DB_LOGGING
  CORS_ORIGIN
  CORS_CREDENTIALS
)

for var in "${required_vars[@]}"; do
  value=$(njq "$VARS_JSON" "d['$var']")
  if [[ -z "$value" ]]; then
    fail "$var: ${RED}NOT SET${NC}"
  else
    case "$var" in
      JWT_SECRET)   display="${value:0:20}..." ;;
      DATABASE_URL) display="${value:0:35}..." ;;
      REDIS_URL)    display="${value:0:35}..." ;;
      *)            display="$value" ;;
    esac
    ok "$var = ${DIM}$display${NC}"
  fi
done

# ── 4. Configuration quality checks ───────────────────────────────────────────
section "4. Configuration checks"

NODE_ENV_VAL=$(njq "$VARS_JSON" "d.NODE_ENV")
DB_SYNC=$(njq "$VARS_JSON" "d.DB_SYNCHRONIZE")
CORS=$(njq "$VARS_JSON" "d.CORS_ORIGIN")
JWT=$(njq "$VARS_JSON" "d.JWT_SECRET")
DB_URL=$(njq "$VARS_JSON" "d.DATABASE_URL")
REDIS_URL_VAL=$(njq "$VARS_JSON" "d.REDIS_URL")

[[ "$NODE_ENV_VAL" == "production" ]] \
  && ok "NODE_ENV=production" \
  || warn "NODE_ENV='$NODE_ENV_VAL' (expected: production)"

[[ ${#JWT} -ge 64 ]] \
  && ok "JWT_SECRET length ok (${#JWT} chars)" \
  || fail "JWT_SECRET too short (${#JWT} chars, minimum 64)"

if [[ "$DB_SYNC" == "true" ]]; then
  warn "DB_SYNCHRONIZE=true — ok for initial setup; run 'make db-sync-off' after first successful deploy"
else
  ok "DB_SYNCHRONIZE=false — using migrations"
fi

[[ "$CORS" != "*" && -n "$CORS" ]] \
  && ok "CORS_ORIGIN=$CORS" \
  || warn "CORS_ORIGIN='${CORS:-not set}' — update to your Railway domain once available"

echo "$DB_URL" | grep -q "railway.internal" \
  && ok "DATABASE_URL → Railway internal network" \
  || { [[ -n "$DB_URL" ]] && warn "DATABASE_URL not pointing to Railway internal network" || true; }

echo "$REDIS_URL_VAL" | grep -q "railway.internal" \
  && ok "REDIS_URL → Railway internal network" \
  || { [[ -n "$REDIS_URL_VAL" ]] && warn "REDIS_URL not pointing to Railway internal network" || true; }

# ── 5. Public domain & health check ───────────────────────────────────────────
section "5. Public domain & health"

DOMAIN=$(njq "$STATUS_JSON" "
  (function(){
    var envs=((d.environments||{}).edges)||[];
    if(!envs.length) return '';
    var instances=((envs[0].node.serviceInstances||{}).edges)||[];
    var svc=instances.find(function(i){return i.node.serviceName==='backend';});
    if(!svc) return '';
    var domains=((svc.node.domains||{}).serviceDomains)||[];
    return domains.length ? domains[0].domain : '';
  })()
")

if [[ -z "$DOMAIN" ]]; then
  warn "No public domain yet — run: railway domain"
  info "Health check skipped (no domain)"
else
  ok "Public domain: ${CYAN}https://$DOMAIN${NC}"
  info "Checking /api/v1/health..."
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$DOMAIN/api/v1/health" 2>/dev/null || echo "000")
  case "$HTTP_CODE" in
    200) ok "Health endpoint ${GREEN}200 OK${NC} — backend is up" ;;
    000) warn "Health endpoint unreachable (timeout) — may still be deploying" ;;
    *)   fail "Health endpoint returned HTTP $HTTP_CODE" ;;
  esac
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────${NC}"
TOTAL=$((PASS + WARN + FAIL))
echo -e "  ${GREEN}✔ $PASS passed${NC}   ${YELLOW}⚠ $WARN warnings${NC}   ${RED}✘ $FAIL failed${NC}   (${TOTAL} checks)"
echo ""

if [[ $FAIL -gt 0 ]]; then
  echo -e "  ${RED}Some checks failed — review the items above.${NC}"
  exit 1
elif [[ $WARN -gt 0 ]]; then
  echo -e "  ${YELLOW}Ready with warnings — see items above.${NC}"
  exit 0
else
  echo -e "  ${GREEN}All checks passed — backend is healthy.${NC}"
  exit 0
fi
