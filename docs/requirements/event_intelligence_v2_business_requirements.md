# Business Requirements

## Project: Local Event Intelligence Platform

### Purpose

This product is a local intelligence platform that helps businesses act on
major life-event and market-activity signals associated with likely spending.

The current data asset is heavily oriented around new home sales scraped from
Zillow and Redfin. That dataset remains strategically important, but it is now
just one signal family inside a broader platform.

The platform must support ingestion, normalization, scoring, targeting,
analytics, and delivery for multiple local signal types across industries such
as healthcare, legal, home services, real estate, financial services, and B2B
professional services.

This is not a generic contact database and not a ZoomInfo clone. The core value
is signal intelligence tied to local change, local intent, and local spending
probability.

## Product Positioning

Customers do not buy raw records. They buy timely local intelligence that helps
them decide:

- who to contact
- why now
- how urgent the opportunity is
- what channel to use

Examples:

- A home sale may indicate likely purchases for dentists, movers, landscapers,
  remodelers, and local financial advisors.
- A solar or remodel permit may indicate contractor demand, financing needs, or
  follow-on services.
- A probate filing may indicate legal, estate, investor, or cleanup demand.
- A new business registration may indicate likely demand for accountants,
  printers, attorneys, payroll providers, and commercial vendors.
- A physician directory within a service area may support outreach by adjacent
  healthcare providers such as acupuncturists, imaging centers, or specialists.

## Strategic Objectives

The platform must support:

1. Multi-signal ingestion from public web, search, and partner sources.
2. Event normalization into a consistent event model.
3. Entity resolution across addresses, businesses, people, and organizations.
4. Lead scoring and ranking by use case and industry.
5. Audience targeting by service area, industry, and campaign rules.
6. Multi-channel delivery including analytics exports and direct mail.
7. Historical timelines to support repeatable prospecting and attribution.
8. Migration of the existing home-sales database into the new model without
   losing source lineage or historical utility.
9. Reuse proven v1 operational patterns where they still fit, especially around
   idempotent batch jobs, direct-mail workflows, and raw-data archival.

## Scope

### In Scope

- Event-centric data model
- Reference-data support for market-coverage products such as provider or
  physician rosters
- Migration path for existing Zillow/Redfin home-sales data
- Support for Google Cloud SQL Postgres as the primary operational database
- Use of Bright Data Web Unlocker and SERP-based discovery in ingestion
- Delivery support for CSV, Google Sheets-ready exports, email-ready files,
  SMS-ready exports, and PostGrid
- Analytics support via Evidence.dev
- Subscriber and service-area targeting
- Event scoring and event-to-industry mapping
- Raw-source retention and normalization lineage
- GCS-based archival or offloading of large and old raw data for cost control

### Out of Scope for Initial Planning

- Full CRM replacement
- Full omnichannel campaign orchestration UI
- Nationwide real-time streaming architecture
- Consumer-facing applications
- High-volume outbound messaging orchestration in phase one

## Core Product Principles

### 1. Event-First, Not Source-First

The product should organize around normalized events and derived signals, not
around the structure of any source website or permit portal.

### 2. Entity Graph Over Single-Table Records

The system must support links between properties, people, businesses,
organizations, licenses, and geographic areas.

### 3. Source Lineage Is Mandatory

Every normalized record must preserve provenance to raw source material so that
quality issues can be diagnosed and scrapers can be improved.

### 4. Configurable Targeting

Different industries care about different combinations of recency, geography,
value, event type, and confidence. Targeting and scoring must be configurable.

### 5. Delivery Must Be Operational

Signals only matter if they can be routed into usable downstream outputs such as
mail files, dashboards, exports, or customer-specific lead feeds.

### 6. Begin With The End In Mind

Even if development is staged slowly, the schema and workflows must anticipate a
broader platform that serves multiple industries, multiple delivery channels,
and both residential and commercial use cases.

## Signal Families

The platform should support multiple categories of signals.

### Property and Address Signals

- home sales
- listings and listing changes
- building permits
- solar permits
- remodel permits
- code enforcement and other municipal filings

### Personal or Household Signals

- probate filings
- estate-related public records
- change-of-residence indicators when legally and operationally appropriate

### Business Signals

- business registrations
- new business openings
- ownership or status changes
- licensing and permit changes

### Professional and Service-Area Signals

- physician or provider rosters in a service area
- professional office openings or relocations
- practice-level changes relevant to healthcare outreach

Some of these may be true life events and some may be market-coverage datasets.
The platform should support both, but they must be clearly distinguished in the
data model and product packaging.

## Phase-One Priorities

The first expansion beyond legacy home sales should prioritize:

- permits
- business registrations
- foundational support for provider or physician coverage datasets

The platform should support both residential and commercial intelligence, even
if initial source coverage is narrower by market.

## Primary Users

### Internal Users

- product and operations staff managing source coverage and quality
- analysts exploring signal performance and market opportunities
- sales and account teams preparing audience exports

### Customer Types

- home service businesses
- dentists and other local healthcare practices
- attorneys and legal service providers
- landscapers and contractors
- investors and real estate service providers
- accountants and local B2B vendors

The primary customer unit should be a local office location rather than a
national account abstraction.

## Key Workflows

### Workflow 1: Source Ingestion

The system collects raw records from:

- Zillow and Redfin
- municipal portals
- public registries
- search-driven discovery workflows
- future structured imports from internal legacy systems

### Workflow 2: Normalization

Raw records are transformed into standard entities and events with consistent
types, dates, values, locations, and confidence levels.

### Workflow 3: Entity Resolution

The platform links events to known addresses, parcels, businesses, people,
organizations, and service areas where applicable.

### Workflow 4: Scoring

The platform calculates lead and relevance scores based on:

- event type
- recency
- estimated economic value
- source confidence
- local relevance
- industry fit
- customer-specific rules

### Workflow 5: Audience Matching

The system matches signals to subscribers based on:

- industry
- geography
- office location
- service area
- exclusivity rules
- delivery preferences
- campaign filters

### Workflow 6: Delivery and Measurement

Signals are made available through:

- exports
- dashboards
- Evidence.dev analytics outputs
- Google Sheets-ready lead delivery
- email-ready outputs for Mailchimp or SendGrid workflows
- SMS-ready outputs for Twilio workflows
- direct-mail job preparation through PostGrid

The platform must track which signals were delivered, when, and through which
channel.

## High-Level Conceptual Model

The conceptual architecture should be:

`Entity -> Event -> Signal -> Audience Match -> Delivery -> Outcome`

Example:

`Property at 123 Maple St -> kitchen remodel permit -> contractor lead -> HVAC audience match -> direct mail batch -> response tracking`

## Core Data Domains

### Entities

Entities are durable objects that can accumulate multiple events over time.

Initial entity types:

- property
- address
- parcel
- person
- business
- organization
- professional practice
- geography or service area
- office location

### Events

Events are time-based facts associated with one or more entities.

Example event types:

- home_sale_closed
- building_permit_issued
- solar_permit_issued
- probate_filed
- business_registered
- physician_practice_opened

### Signals

Signals are derived commercial interpretations of events.

Examples:

- high-value dental prospect
- contractor follow-up lead
- investor probate opportunity
- healthcare referral outreach target

### Audience Matches

Audience matching represents the rule-based or scored fit between a signal and a
specific subscriber, vertical, or campaign.

### Deliveries

Deliveries represent what was actually sent or made available downstream.

## Geographic Model

Phase one should support service areas defined by:

- ZIP code
- town or city
- county

Custom polygons may be added later if the business proves out and geographic
precision becomes a material product advantage.

## Functional Requirements

### Data Management

- The system must retain raw payloads or raw references for auditability.
- The system must support normalized fields plus flexible source-specific
  attributes.
- The system must support reprocessing when parsers or scoring logic change.
- The system must preserve historical event timelines.

### Matching and Scoring

- Scoring rules must be configurable by event family and customer segment.
- The system must support confidence scores for parsing and entity resolution.
- The system must support de-duplication across overlapping sources.

### Delivery

- The system must prevent duplicate delivery according to configurable rules.
- The system must support customer-specific service areas.
- The system must track delivery status and downstream identifiers.
- The system must support direct-mail workflow preparation for PostGrid.
- The system should support channel-specific export layers for direct mail,
  Google Sheets delivery, email workflows, and SMS workflows.

### Analytics

- The platform must expose tables or models suitable for Evidence.dev.
- The platform must support reporting on event volume, source quality, delivery
  volume, subscriber coverage, and campaign performance.
- The platform should support both internal operational reporting and later
  customer-facing lead views.

## Non-Functional Requirements

- Prioritize correctness and explainability over premature complexity.
- Support incremental expansion to new signal families without schema collapse.
- Make ingestion failures and parser errors observable.
- Design for batch-first processing with future room for more frequent refreshes.
- Keep source adapters isolated so that changes in one source do not destabilize
  the full platform.
- Prefer a SQL-first and script-first operating model initially.
- Offload large or aged raw artifacts to Google Cloud Storage to control
  operational database cost and local disk pressure.

## Initial Success Metrics

- Existing home-sales data migrated into the new event model without losing key
  history or source lineage
- At least three non-home-sale signal families modeled in the platform
- Subscriber targeting and delivery working for at least two distinct verticals
- Evidence.dev dashboards available for operational reporting
- PostGrid-ready output available for direct-mail workflows

## Major Open Decisions

- Exact packaging of market-coverage datasets such as physician rosters versus
  true event-driven products
- Which initial verticals deserve first-class optimization
- How subscriber delivery rules should vary across exclusive, shared, and hybrid
  products
- How much person-level data is intentionally stored and under what compliance
  constraints
- How much customer-facing analytics should live in Evidence.dev versus simple
  lead delivery surfaces such as Google Sheets
