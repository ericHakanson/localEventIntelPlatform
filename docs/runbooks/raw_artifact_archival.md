# Runbook: Raw Artifact Archival

## Purpose

Phase one keeps raw-artifact lineage queryable while pushing bulky or aging raw
content toward GCS for cost control and operational safety.

## Policy

- operational retention target: 365 days
- large artifacts should prefer pointer storage over inline storage
- archived artifacts must keep a stable pointer in Postgres
- archival must never break normalized lineage back to source material

## Archive Candidate Criteria

- `raw_artifact.archived_at IS NULL`
- `fetched_at < NOW() - INTERVAL '365 days'`
- `storage_mode = 'inline'` or local-only content is still referenced
- no active incident or parser-diagnostics hold is in place

## Archive Flow

1. identify candidate raw artifacts
2. copy or confirm the artifact in GCS
3. update `storage_mode` to `gcs_pointer`
4. write the canonical `storage_uri`
5. stamp `archived_at`
6. verify the pointer remains resolvable

## Verification Queries

```sql
SELECT raw_artifact_id, storage_mode, storage_uri, fetched_at, archived_at
FROM raw_artifact
WHERE archived_at IS NOT NULL
ORDER BY archived_at DESC
LIMIT 100;
```

```sql
SELECT COUNT(*) AS broken_archive_pointers
FROM raw_artifact
WHERE archived_at IS NOT NULL
  AND (storage_uri IS NULL OR storage_mode <> 'gcs_pointer');
```

## Failure Handling

- do not delete local or inline copies before the GCS pointer is verified
- if archival fails mid-run, leave the artifact in its prior readable state
- reruns must be safe and must not create duplicate archive records
