# ADR 0003: Phase-One Scoring Strategy

## Status

Accepted

## Date

2026-03-10

## Context

The platform needs lead ranking early, but there is not yet enough outcome
history to justify learned scoring models. Different local verticals care about
different event and reference signals.

## Decision

Phase one scoring is rule-based and vertical-specific.

- scoring logic must be stored as data, not hard-coded constants only
- score models must support per-vertical configuration
- score outputs must preserve component-level explainability
- customer-fit overlays must not rewrite underlying source facts

## Consequences

- scoring can be tuned safely without schema drift
- analytics can explain why a lead ranked highly
- future learned models can be added later behind the same scoring interfaces
