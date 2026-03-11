# ADR 0002: Service Area Modeling

## Status

Accepted

## Date

2026-03-10

## Context

Phase one must support local office targeting without building custom geospatial
polygons or a GIS-heavy system too early. The project is intentionally focused
on a small number of pilot markets and needs a simple, auditable targeting
model.

## Decision

Phase one service areas are modeled as discrete records attached to an office
location using only:

- ZIP code
- city or town
- county

Custom polygons and radius logic are deferred. The `service_area` table remains
simple enough to drive subscriber targeting, delivery eligibility, and reporting
without requiring geospatial infrastructure.

## Consequences

- matching logic stays simple and testable in SQL
- office-level targeting remains first-class
- future polygon support will require additive design, not a breaking rewrite
