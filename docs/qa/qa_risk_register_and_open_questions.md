# QA Risk Register And Open Questions

## Role Of This Document

This document captures the main implementation risks, QA concerns, and product
questions that should be resolved before heavy build-out. It is intended to keep
future development disciplined and prevent the platform from drifting into a
narrow real-estate schema again.

## High-Risk Areas

### 1. Event Taxonomy Drift

Risk:

- event types get added ad hoc
- similar signals are modeled inconsistently
- analytics become unreliable across sources

QA focus:

- require canonical event types
- require source-to-event mapping tests
- require explicit versioning when normalization logic changes

### 2. Property-Centric Schema Regression

Risk:

- implementation quietly assumes everything has a property
- business, practice, or person-based signals become second-class citizens

QA focus:

- require fixtures that prove non-property events can exist cleanly
- require entity resolution tests across business and professional datasets

### 3. Duplicate And Near-Duplicate Events

Risk:

- the same underlying event appears across multiple sources
- customers receive redundant leads
- scoring is inflated by duplicate evidence

QA focus:

- define duplicate rules by event family
- test cross-source de-duplication
- test customer-specific duplicate suppression windows

### 4. Weak Source Lineage

Risk:

- normalized records cannot be traced back to source artifacts
- parser bugs are expensive to diagnose
- customers challenge record validity

QA focus:

- every event must reference source lineage
- reprocessing must not destroy historical provenance

### 5. Unclear Handling Of Reference Data

Risk:

- provider rosters, business directories, and current-state datasets are forced
  into event semantics
- downstream logic becomes confusing

QA focus:

- explicitly test event data versus reference data workflows
- require clear model boundaries for each dataset family

### 6. Delivery Mismatch

Risk:

- technically valid signals do not translate into usable customer outputs
- direct-mail records fail address or formatting requirements

QA focus:

- validate delivery payload completeness
- test PostGrid mapping rules
- test batch idempotency and suppression behavior

### 7. Office-Level Targeting Ambiguity

Risk:

- subscriber logic drifts toward account-level abstractions too early
- service-area matching becomes too coarse for local operators

QA focus:

- require office-location fixtures
- test delivery generation at the office-location level
- ensure parent-account support does not replace local targeting semantics

### 8. Storage Cost And Retention Drift

Risk:

- raw artifacts accumulate in Postgres or local disk
- storage costs and operational friction increase silently

QA focus:

- test archive-pointer behavior
- validate GCS handoff workflows
- require retention and purge policies for bulky raw artifacts

## Minimum QA Gates For Any Signal Family

Before a new signal family is considered production-ready, it should pass:

1. Source coverage validation for at least one real market
2. Parser accuracy review against sampled raw documents
3. Duplicate detection checks
4. Entity resolution confidence review
5. Signal scoring sanity review
6. Subscriber matching review
7. Delivery-format validation
8. Evidence.dev reporting validation
9. Archive and retention validation

## Suggested Acceptance Criteria For Phase One

### Legacy Home Sales Migration

- existing Zillow/Redfin history loads into the new event schema
- original source identifiers remain queryable
- migrated counts reconcile against the legacy database within an agreed margin

### Multi-Signal Support

- at least one non-property signal family is modeled without schema workarounds
- at least one reference-data dataset can coexist without pretending to be an
  event stream
- permits and business registrations are both represented in production-ready
  schemas

### Delivery

- a subscriber can be configured with service area, industry, and delivery rules
- a subscriber office location can be configured and targeted independently
- a delivery batch can be generated without duplicates
- a PostGrid-ready output can be produced from matched signals
- at least one non-mail channel export is available, such as Google Sheets,
  email, or SMS

### Analytics

- Evidence.dev can answer basic operational questions without raw table spelunking
- source quality and delivery volume are visible by date and signal family
- customer-facing lead views remain optional and do not distort the operational
  schema

## Architectural Questions That Need Product Answers

### Product Boundary

1. Reference-data products such as physician directories are in scope. Should
   they be packaged and reported separately from event-driven products?
2. Should reference-data products be allowed to participate in the same delivery
   and scoring framework as event-driven products, or only share the underlying
   entity and audience infrastructure?

### Customer And Packaging

3. Are subscribers buying exclusive leads, shared leads, or a mix depending on
   vertical?
4. The primary customer unit is a specific office location. What parent-account
   structure, if any, is needed beyond that?

### Geography

5. Phase one service areas are ZIP, town or city, and county. Do you also need
   radius support early, or can it wait with polygons?
6. Is the product initially focused on a few local markets or designed for broad
   multi-market rollout from day one?

### Data Model And Compliance

7. How much person-level data do you want to retain for probate or household
   signals?
8. Are there categories you want to avoid entirely for legal, ethical, or brand
   reasons?
9. What raw-artifact retention period is acceptable?

### Scoring And Outcome Tracking

10. Do you want one global lead score, or separate scores by vertical and use
    case?
11. Do you expect to track campaign outcomes later, such as mail response or
    closed business, inside this platform?

### Delivery

12. PostGrid, Mailchimp or SendGrid, Twilio, and Google Sheets are all in the
    long-term vision. Which one or two channels matter in phase one besides mail?
13. Evidence.dev may become customer-facing later. What customer-facing
    experience matters more first: dashboards or simple lead delivery?

### Operating Model

14. Claude should plan around a SQL-first and scripts-first operating model. What
    is the minimum internal application layer you would actually pay to build
    early, if any?
15. Database-driven operations are acceptable initially. Which workflows would
    become too painful without even a thin operator UI?

## Recommended Immediate Decisions

To keep the architecture coherent, the next decisions should be:

1. Confirm the initial verticals to optimize for.
2. Confirm phase-one channel priorities beyond PostGrid.
3. Confirm raw-artifact retention and archive policy.
4. Confirm delivery packaging and exclusivity rules by product type.
5. Confirm what outcomes, if any, the platform should measure beyond delivery.
