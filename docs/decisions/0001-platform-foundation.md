# ADR 0001: Platform Foundation

## Status

Accepted

## Date

2026-03-06

## Context

The v1 system was built around recently sold real-estate data, direct mail, and
batch-oriented automation. The v2 platform must support a broader local
intelligence model without losing the operational lessons that made v1 useful.

The main risks at this stage are:

- drifting back into a property-only schema
- treating reference datasets as if they were time-based events
- overbuilding an application layer before the product model is stable
- storing too much raw data in expensive or operationally fragile places

## Decision

The platform will adopt the following foundation decisions.

### 1. Commercially Event-First, Technically Entity-Aware

The product will be sold around signals and events, but the data model will
maintain a shared entity layer so multiple signal families can accumulate around
the same addresses, businesses, people, and office locations.

### 2. Event Data And Reference Data Are Separate First-Class Domains

Time-based records such as permits, home sales, and business registrations will
be modeled as events. Coverage datasets such as physician or provider rosters
will be modeled as reference data, even if they use shared matching, delivery,
and audience infrastructure.

### 3. Office Location Is The Primary Customer Target

Subscriber targeting, service-area matching, and delivery should resolve to the
office-location level first. Parent-account abstractions may be added later, but
they must not replace the local operating model.

### 4. Phase One Is SQL-First And Script-First

The early system should be built with Postgres schema, migrations, views, marts,
and batch scripts before investing in a heavier application layer.

### 5. Cloud SQL Stores Operational Data, GCS Stores Bulky Raw Artifacts

Normalized operational data will remain in Cloud SQL. Large or aging raw
artifacts should be archived to Google Cloud Storage with lineage pointers kept
in Postgres.

### 6. Delivery Is Channel-Ready Before It Is Fully Orchestrated

Phase one will prioritize reliable exports, ledgers, and batch delivery support
for PostGrid and future channels such as Google Sheets, email, and SMS. A full
omnichannel orchestration UI is deferred.

## Consequences

### Positive

- The schema can support both residential and commercial use cases.
- Reference products can be added without polluting event semantics.
- Claude can build incrementally from SQL and scripts without application guesswork.
- Storage growth is easier to control operationally and financially.
- Direct-mail lessons from v1 remain reusable.

### Negative

- Some workflows may remain manual longer than a typical SaaS build.
- Customer-facing experiences may initially rely on exports or Evidence views
  rather than dedicated UI.
- Reference datasets will require explicit modeling work rather than shortcuts.

## Follow-Up

- Add ADRs for service-area modeling, scoring strategy, and delivery packaging.
- Revisit application-layer scope only after the first end-to-end event and
  reference workflows are stable.

