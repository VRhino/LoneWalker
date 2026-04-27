# LoneWalker — Railway operations
# Run from project root. Requires: npm i -g @railway/cli
.DEFAULT_GOAL := help

BACKEND_DIR := backend

.PHONY: help railway-setup deploy logs status vars open \
        db-shell db-enable-postgis db-migrate db-sync-off

help:
	@echo ""
	@echo "  LoneWalker — Railway CLI targets"
	@echo ""
	@echo "  Setup"
	@echo "    railway-setup         First-time Railway project setup"
	@echo ""
	@echo "  Deploy & monitor"
	@echo "    deploy                Deploy backend to Railway"
	@echo "    logs                  Stream backend logs"
	@echo "    status                Show project / service status"
	@echo "    vars                  List all environment variables"
	@echo "    open                  Open Railway dashboard in browser"
	@echo ""
	@echo "  Database"
	@echo "    db-shell              Open interactive PostgreSQL shell (psql)"
	@echo "    db-enable-postgis     Enable PostGIS extension (run once after setup)"
	@echo "    db-migrate            Run pending TypeORM migrations"
	@echo "    db-sync-off           Set DB_SYNCHRONIZE=false (use after initial setup)"
	@echo ""

# ── Setup ──────────────────────────────────────────────────────────────────────

railway-setup:
	@bash scripts/setup-railway.sh

# ── Deploy & monitor ───────────────────────────────────────────────────────────

deploy:
	railway up $(BACKEND_DIR) --path-as-root --service backend --detach

logs:
	railway logs

status:
	railway status

vars:
	railway variables

open:
	railway open

# ── Database ───────────────────────────────────────────────────────────────────

db-shell:
	railway connect postgresql

db-enable-postgis:
	@echo "Connecting to PostgreSQL — run this query then exit with \\q:"
	@echo ""
	@echo "  CREATE EXTENSION IF NOT EXISTS postgis;"
	@echo ""
	railway connect postgresql

db-migrate:
	cd $(BACKEND_DIR) && railway run pnpm run db:migrate

db-sync-off:
	railway variables set DB_SYNCHRONIZE=false
	@echo "DB_SYNCHRONIZE set to false. Redeploy to apply: make deploy"
