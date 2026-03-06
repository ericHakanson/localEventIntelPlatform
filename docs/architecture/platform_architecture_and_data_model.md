# Platform Architecture And Data Model

## Planning Goal

This document translates the business requirements into a practical technical
shape for implementation. It is intended as a planning baseline for future
development work, including handoff to Claude.

## Recommended Architecture

### Core Stack

- Operational database: Google Cloud SQL for PostgreSQL
- Scraping access: Bright Data Web Unlocker
- Search discovery: SERP-driven acquisition workflows
- Analytics and internal reporting: Evidence.dev
- Direct-mail integration: PostGrid
- Future channel integrations: Mailchimp or SendGrid, Twilio, Google Sheets

### Recommended Supporting Components

- Raw object storage in Google Cloud Storage for scraped pages, PDFs, and source
  payload archives
- A job runner or orchestrator for scheduled ingestion, normalization, scoring,
  and delivery jobs
- A small internal admin or operator interface later, but not required for phase
  one if SQL-first operations are acceptable
- Strong shell-safe runbooks because the operator model is terminal-first and
  non-engineering-friendly

Cloud SQL should store normalized operational data. Large raw artifacts should
be referenced from object storage rather than stored directly in Postgres unless
they are small enough to justify inline retention. Old and bulky raw data should
be handed off to GCS deliberately for cost containment and to avoid local disk
pressure, which was already a v1 operational issue.

## Pipeline Stages

### 1. Source Discovery

Purpose:

- discover source URLs, search results, and record identifiers
- capture source metadata
- queue items for retrieval

Inputs:

- SERP queries
- known source URLs
- legacy source lists

Outputs:

- source discovery records
- fetch queue items

### 2. Raw Acquisition

Purpose:

- fetch HTML, PDFs, JSON, and other raw documents
- retain enough source material for reprocessing and audit

Key requirements:

- request logging
- retry policy
- source-specific throttling
- fetch status tracking

### 3. Parsing And Normalization

Purpose:

- extract structured fields from raw artifacts
- map source-specific records into normalized entity and event schemas

Normalization outputs should include:

- canonical event type
- observed event date
- source publication date when applicable
- location and address fields
- business or person names when applicable
- amount or value fields
- parser confidence
- normalization version

### 4. Entity Resolution

Purpose:

- connect normalized records to known entities
- create new entities when confidence thresholds are met
- flag uncertain matches for review or lower-confidence use

Entity resolution should be explicit and auditable. A match should store:

- source entity keys
- matching method
- confidence score
- resolution version

### 5. Signal Derivation

Purpose:

- convert events into commercially useful signal interpretations
- support multiple possible signals from one event

Example:

- a home sale can produce signals for dentists, landscapers, movers, remodelers,
  and financial services

### 6. Audience Matching

Purpose:

- determine which subscribers or campaigns should receive which signals

Rules may consider:

- office location
- service area overlap
- industry fit
- lead score threshold
- exclusivity constraints
- recency window
- customer-specific suppressions

### 7. Delivery And Measurement

Purpose:

- create deliverable outputs
- send or stage records for downstream channels
- record what was delivered and measure downstream outcomes

## Recommended Logical Data Model

### Source Tables

These preserve source acquisition history and parsing lineage.

- `source_system`
- `source_endpoint`
- `source_discovery_item`
- `raw_artifact`
- `fetch_attempt`
- `parse_run`
- `normalized_record`
- `archive_pointer`

### Core Entity Tables

- `entity`
- `entity_type`
- `entity_identifier`
- `entity_address`
- `entity_relationship`
- `office_location`
- `service_area`

The `entity` table should be generic enough to support properties, businesses,
people, and practices without hard-coding the entire platform around property.
`office_location` should be treated as a first-class operational target because
the initial customer unit is a specific local office rather than an abstract
enterprise account.

### Event Tables

- `event`
- `event_type`
- `event_entity_link`
- `event_attribute`
- `event_lineage`

Recommended event fields:

- `event_id`
- `event_type_id`
- `event_date`
- `observed_at`
- `source_system_id`
- `status`
- `estimated_value`
- `confidence_score`
- `raw_artifact_id`
- `normalization_version`

### Signal And Scoring Tables

- `signal`
- `signal_type`
- `signal_event_link`
- `score_model`
- `signal_score`
- `industry_mapping`

Scores should support component-level explainability, not just a single final
number.

Recommended score components:

- recency
- event-value
- source-confidence
- geo-fit
- industry-fit
- entity-quality
- customer-fit

### Customer And Delivery Tables

- `subscriber`
- `subscriber_profile`
- `subscriber_vertical`
- `subscriber_office_location`
- `subscriber_service_area`
- `campaign`
- `audience_match`
- `delivery_batch`
- `delivery_item`
- `delivery_channel`
- `delivery_outcome`

### Analytics-Facing Models

Evidence.dev will be more usable if backed by stable reporting models or marts
such as:

- `mart_event_volume_by_type`
- `mart_source_quality`
- `mart_signal_delivery_performance`
- `mart_subscriber_coverage`
- `mart_geo_market_summary`

## Key Modeling Decisions

### Entity-First Versus Event-First

The platform is commercially event-first, but technically it should maintain a
shared entity graph so timelines and cross-signal intelligence accumulate.

### Property Is Important But Not Universal

Many valuable signals attach to addresses, but some attach to businesses,
professionals, or households. The schema should not require every event to map
to a parcel or property record.

### Distinguish Event Data From Reference Data

Some datasets are event streams. Others are coverage lists or reference
directories. Physician rosters are a current example. Those should not be forced
into the same semantics without deliberate modeling.

Recommended split:

- event data: time-based changes with an event date
- reference data: current-state entities useful for audience building

Reference datasets are in scope now, not later, so this split should exist in
the first schema version rather than as a retrofit.

### Local-First Customer Model

The system should optimize for local office operations. Subscriber matching,
delivery, and reporting should resolve to the office-location level even if
parent-account structures are added later.

### Residential And Commercial Scope

The data model should not assume residential-only semantics. Addresses,
businesses, permits, and services should support commercial use cases from the
start even if early scoring logic is still more mature for residential signals.

## Migration Strategy For Existing Home-Sales Database

### Phase 1

- inventory current tables and key source fields
- identify what maps directly to `entity`, `event`, and `raw_artifact`
- preserve original source identifiers from Zillow and Redfin

### Phase 2

- backfill normalized `home_sale_closed` events
- create linked property or address entities
- retain original payload references and scrape timestamps

### Phase 3

- derive industry-specific signals from the migrated home-sale events
- compare output counts and lead quality against the current system

### Phase 4

- carry forward proven v1 direct-mail concepts such as ledgers, campaign states,
  idempotent batch generation, and reconciliation patterns where they still
  apply cleanly in the broader platform

## Scoring Approach

### Recommended Initial Approach

Start with rule-based scoring stored as data, not code-only constants.

Why:

- easier to audit
- easier to tune per vertical
- better aligned with a planning-first phase
- simpler for Claude to implement incrementally

### Future Approach

Allow later expansion into learned scoring models once:

- enough labeled delivery outcomes exist
- scoring inputs are stable
- attribution quality is acceptable

## Delivery Architecture

### Channels

- CSV and spreadsheet-ready exports
- Google Sheets delivery or synchronization layer
- internal reporting tables for Evidence.dev
- direct-mail job preparation for PostGrid
- email-audience exports for Mailchimp or SendGrid
- SMS-audience exports for Twilio
- future API or customer feed delivery if needed

### Delivery Requirements

- idempotent batch creation
- duplicate suppression
- customer-level filters
- clear status model
- downstream identifier storage

The long-term product direction is omnichannel, but phase one should prioritize
channel-ready exports and ledgering over a full orchestration application.

For PostGrid, expect a mapped output layer rather than coupling normalized event
records directly to the API payload.

For Google Sheets delivery, treat Sheets as a downstream presentation layer, not
the system of record.

## Data Quality And Observability

The platform should track:

- source coverage by market and date
- fetch success rate
- parser success rate
- normalization error classes
- duplicate rate
- unresolved entity rate
- delivery success rate

Evidence.dev should support internal dashboards first but should be modeled with
the option to expose customer-facing lead views later.

These should become first-class Evidence.dev dashboards early.

## Security And Compliance Planning

The exact compliance boundary is still open, but the architecture should assume:

- role-based access to sensitive records
- auditability of source and delivery history
- explicit retention rules for raw artifacts and derived data
- careful handling of person-level data and regulated professional data

Person-level retention for probate or similar datasets remains undecided, so the
schema should make field-level minimization and retention policies possible.

## Recommended Phase Order

1. Finalize core data model and event taxonomy.
2. Finalize the reference-data model alongside the event model.
3. Map legacy home-sale data into the new schema.
4. Stand up ingestion lineage, raw artifact retention, archival policies, and
   normalization versioning.
5. Add permits and business registrations as the first non-home-sale signal
   families.
6. Implement rule-based scoring and office-level subscriber matching.
7. Add delivery batches and channel-ready export support for PostGrid, Sheets,
   email, and SMS workflows.
8. Build Evidence.dev marts and operational dashboards.
9. Add customer-facing reporting or lead views only after delivery semantics are
   stable.
