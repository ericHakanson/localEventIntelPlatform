# ADR 0004: Delivery Packaging For Phase One

## Status

Accepted

## Date

2026-03-10

## Context

Phase one needs real customer delivery, but not a full omnichannel campaign
application. PostGrid is already established, Google Sheets is the chosen second
surface, and lead packaging may vary by product.

## Decision

Phase one delivery is channel-ready rather than fully orchestrated.

- PostGrid is the first fulfillment channel
- Google Sheets is the primary non-mail delivery surface
- email and SMS remain future-ready export shapes, not orchestrated channels
- lead exclusivity is configurable by product using `exclusive`, `shared`, and
  `hybrid` modes
- outcome tracking ends at delivery state in phase one

Reference-data products must be packaged and reported separately from
event-driven products even if they share delivery infrastructure.

## Consequences

- implementation can stay script-first and operationally simple
- delivery tables need stable external IDs and batch semantics
- customer-facing reporting can grow later without changing the system of record
