# Local Event Intelligence Platform

Planning repository for a multi-signal local intelligence platform centered on
life-event and market-activity signals that predict local spending.

## Repository Structure

- `docs/`: planning, requirements, architecture, QA, handoffs, and runbooks
- `sql/`: schema migrations, views, marts, and seed data
- `scripts/`: ingestion, normalization, scoring, delivery, and ops jobs
- `config/`: non-secret configuration examples and environment docs
- `templates/`: output templates and payload mappings
- `samples/`: redacted source artifacts and sample payloads
- `tests/`: SQL and script-level checks
- `archive/`: superseded artifacts worth retaining

## Current Planning Assumptions

- Existing data from Zillow and Redfin will be migrated into the new platform.
- Google Cloud SQL for PostgreSQL is the primary operational datastore.
- Bright Data Web Unlocker and SERP workflows support data acquisition.
- Evidence.dev will support analytics first and may later support customer-facing
  views.
- PostGrid will support direct-mail fulfillment workflows.
- Mailchimp or SendGrid, Twilio, and Google Sheets are part of the long-term
  omnichannel delivery vision.
- The primary customer target is a local office location with service areas
  defined initially by ZIP, town or city, and county.
- Large and old raw artifacts should be archived to GCS for cost containment.

## Core Planning Docs

- [Business requirements](/Users/erichakanson/projects/localEventIntelPlatform/docs/requirements/event_intelligence_v2_business_requirements.md)
- [Platform architecture and data model](/Users/erichakanson/projects/localEventIntelPlatform/docs/architecture/platform_architecture_and_data_model.md)
- [QA risk register and open questions](/Users/erichakanson/projects/localEventIntelPlatform/docs/qa/qa_risk_register_and_open_questions.md)
- [Codex handoff context from 2026-03-06](/Users/erichakanson/projects/localEventIntelPlatform/docs/handoffs/codex_handoff_context_2026-03-06.md)

## Near-Term Goal

Define a durable event-centric platform shape before implementation begins, so
future build work does not collapse back into a narrow real-estate schema.
