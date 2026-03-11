# Phase One Execution Plan

## Purpose

This document translates the approved phase-one plan into an execution sequence
for implementation in the repository and tracking in Linear.

## Operating Model

- Claude is the primary implementation agent.
- Codex remains in architect and QA role.
- Work should be SQL-first, script-first, and runbook-driven.
- No internal application UI is in scope for phase one.

## Execution Order

### M1 Foundation

- finalize architecture decisions for service areas, scoring, and delivery
- establish seed data for entity types, event types, signal types, delivery
  channels, and initial verticals
- add operator runbooks for local DB access, migrations, and raw-artifact
  archival
- create SQL verification checks for schema and seeds

### M2 Legacy Migration

- inventory the v1 Zillow and Redfin schema and scripts
- map legacy fields into v2 `entity`, `event`, `raw_artifact`, and lineage
  records
- build idempotent migration scripts and reconciliation queries
- preserve source identifiers, scrape timestamps, and raw lineage

### M3 New Event Signals

- implement permit ingestion, parsing, normalization, dedupe, and entity
  resolution
- implement business-registration ingestion, parsing, normalization, dedupe, and
  business-oriented entity resolution
- support residential and commercial records where sources allow it

### M4 Reference Products

- implement provider or physician roster ingestion into `reference_dataset` and
  `reference_record`
- keep reference products packaged separately from event-driven products
- reuse shared entity resolution, targeting, and delivery infrastructure only
  where semantics remain clean

### M5 Scoring And Matching

- implement rule-based, vertical-specific score models
- support explainable component scoring
- make `office_location` and `service_area` first-class matching inputs
- support configurable `exclusive`, `shared`, and `hybrid` product rules

### M6 Delivery And Analytics

- keep PostGrid as the first fulfillment channel
- add Google Sheets as the primary second delivery surface
- add Evidence-facing marts for operational reporting and pilot-market review
- add archival execution and verification flow for 365-day raw-artifact policy

## Issue Design Rules

- every schema, scoring, delivery, or data-semantics issue requires explicit
  acceptance criteria
- every milestone must end with a QA gate issue
- issues should be sized so Claude can complete them with one coherent PR where
  possible
- runbooks and verification SQL should land in the same milestone as the feature
  they validate

## Default Acceptance Themes

- idempotency for migrations and delivery jobs
- explicit lineage from normalized records back to raw artifacts
- clear separation of event and reference data
- office-location targeting over account-level abstractions
- no hidden hard-coded scoring constants
