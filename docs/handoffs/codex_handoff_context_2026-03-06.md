# Codex Handoff Context (As of 2026-03-06)

## 1. What This Project Is

`recently-sold-real-estate` is a data + automation system for:

- scraping recently sold properties (primarily Zillow and Redfin),
- normalizing/upserting them into Postgres,
- enriching property details,
- scoring renovation candidates,
- running direct-mail operations (mailing ledger + PostGrid campaign engine).

Primary operator is non-engineering and works directly in terminal. Reliability and copy/paste-safe runbooks are critical.

## 2. Core Stack

- Python scripts in `scripts/`
- PostgreSQL (Cloud SQL) via local `cloud-sql-proxy`
- GCS archival for raw scrape files
- Looker Studio connected directly to Cloud SQL
- PostGrid for postcard fulfillment + tracker/QR workflow

## 3. Key Files to Read First

- Product spec: `docs/feature-specifications/postgrid_weekly_direct_mail_automation_engine_v1.md`
- Mailing ledger notes: `docs/feature-specifications/mailing_send_ledger.md`
- Detail enrichment docs: `docs/PROPERTY_DETAIL_ENRICHMENT.md`
- Main scripts:
  - `scripts/run_full_cycle.py`
  - `scripts/load_zillow_listings.py`
  - `scripts/enrich_property_details.py`
  - `scripts/score_renovation_candidates.py`
  - `scripts/record_mailing_sends.py`
  - `scripts/dm_generate_weekly_campaign.py`
  - `scripts/dm_approve_campaign.py`
  - `scripts/dm_submit_campaign.py`
- Migrations:
  - `sql/migrations/007_create_detail_enrichment_checkpoints.sql`
  - `sql/migrations/008_fix_checkpoint_unique_constraint.sql`
  - `sql/migrations/012_create_dm_campaign_engine.sql`
  - `sql/migrations/013_extend_mailing_sends_for_mailer_type.sql`

## 4. Direct Mail Engine Build Status

Implementation has progressed through PR-1 to PR-5.1 (reported complete):

- PR-1: schema foundation
  - `dm_*` campaign engine tables created
  - `mailing_sends` extended for contractor/service/campaign/job linkage
- PR-2 and PR-2.1: mailing ledger service-type hardening
  - `record_mailing_sends.py` supports service type-aware inserts and robust validation
  - fingerprint behavior updated to include `mailer_type`
- PR-3 and PR-3.1: weekly draft campaign generator
  - draft generation, suppression logic, cost projections, idempotency, non-draft protection
  - sold-window fix and dedupe/tiebreak improvements
- PR-4: approval workflow
  - strict `draft -> approved` transition + status history
- PR-5 and PR-5.1: submission engine
  - PostGrid submission, idempotency, savepoint-per-job behavior, authoritative reconciliation
  - campaign/job state handling and mailing ledger writes

PostGrid tracker/QR requirements are included in the spec and should be treated as required for production behavior.

## 5. Data Pipeline Status (Scrape/Load/Enrich/Score)

- Large Zillow MA coverage runs were executed; raw HTML exists under `data/raw/zillow/ma/`.
- Loader was switched to single-file processing to avoid batch duplicate-key conflicts caused by duplicate page files from multiple scrape attempts.
- Enrichment encountered hard stop due to local disk exhaustion (`[Errno 28] No space left on device`) when writing detail HTML.
- Scoring pipeline works when DB connectivity is healthy and `DB_SSLMODE` is correct.

## 6. Critical Operational Lessons

1. **Proxy DB connections must use `DB_SSLMODE=disable`** when going through local `cloud-sql-proxy`.
2. Scripts default to `DB_SSLMODE=require` if not overridden.
3. If `DATABASE_URL` is set, it can override per-variable settings. Use `unset DATABASE_URL` for controlled local runs.
4. `cloud-sql-proxy` may fail with ADC token issues (`invalid_grant`, `invalid_rapt`), requiring:
   - `gcloud auth application-default login`
   - `gcloud auth application-default set-quota-project ...`
5. Disk pressure is a recurring operational risk with detail HTML persistence.
6. User shell is `zsh`; glob behavior can fail if patterns do not match.
7. Do not include inline comments on `export` lines (can break shell parsing for user).

## 7. Current Blocker + Immediate Resume Path

### Blocker

- Local disk nearly full due to detail HTML (`data/raw/detail/ma`).

### Resume approach

1. Keep proxy running in dedicated terminal.
2. Connect with explicit DB env + `DB_SSLMODE=disable`.
3. Resume enrichment **without** `--save-html` (or save to external volume).
4. Re-run scoring after enrichment.

## 8. Known Good Connectivity Pattern

```bash
unset DATABASE_URL
export DB_HOST="127.0.0.1"
export DB_PORT="6543"
export DB_NAME="real_estate"
export DB_USER="real_estate_app"
export DB_PASSWORD="<from secure env>"
export DB_SSLMODE="disable"
export PGPASSWORD="$DB_PASSWORD"

psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -c "\conninfo"
```

## 9. Checkpointing in Detail Enrichment

Detail enrichment is checkpointed:

- `detail_enrichment_checkpoints`
- `detail_enrichment_processed_zpids`

Use these for resume/progress diagnostics before restarting long jobs.

## 10. What to Do Next (Priority Order)

1. Free disk space or move HTML output to external storage.
2. Resume enrichment with checkpoint flags:
   - `--resume --retry-failed --force-continue`
3. Re-run renovation scoring for MA.
4. Validate final counts in:
   - `properties`
   - `property_detail_snapshots`
   - `property_renovation_scores`
5. Continue PostGrid tracker/QR integration and reconciliation hardening.

## 11. Security Notes

- Do not commit live secrets.
- `.env` currently contains sensitive API/database values in local environment; treat as confidential.
- Prefer Secret Manager or CI secret injection for production workflows.

## 12. Guidance for Future Codex Sessions

- Prefer small, restartable, idempotent operations.
- Give user copy/paste-ready commands with no ambiguity.
- For long pipelines, always include:
  - preflight connectivity check,
  - progress/health queries,
  - safe resume command,
  - post-run sanity checks.

