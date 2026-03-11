# Runbook: Local DB And Migrations

## Purpose

This runbook defines the safe local pattern for connecting to Cloud SQL through
`cloud-sql-proxy` and applying repository migrations.

## Preconditions

- `cloud-sql-proxy` is running in a separate terminal
- application-default credentials are valid
- `DATABASE_URL` is unset if explicit env vars are being used
- `DB_SSLMODE=disable` is used when connecting through the local proxy

## Known Good Connection Pattern

```bash
unset DATABASE_URL
export DB_HOST="127.0.0.1"
export DB_PORT="6543"
export DB_NAME="real_estate"
export DB_USER="real_estate_app"
export DB_PASSWORD="<from secure env>"
export DB_SSLMODE="disable"
export PGPASSWORD="$DB_PASSWORD"

psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -c "\conninfo"
```

## Migration Order

Apply files in this order:

1. `sql/migrations/001_platform_foundation.sql`
2. `sql/migrations/002_phase_one_configuration.sql`
3. `sql/seeds/001_reference_data.sql`
4. `sql/views/001_operational_views.sql`
5. `sql/marts/001_reporting_marts.sql`

## Apply Migrations

```bash
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -f sql/migrations/001_platform_foundation.sql
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -f sql/migrations/002_phase_one_configuration.sql
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -f sql/seeds/001_reference_data.sql
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -f sql/views/001_operational_views.sql
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -f sql/marts/001_reporting_marts.sql
```

## Verification

```bash
psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=disable" -f tests/sql/001_platform_foundation_checks.sql
```

## Notes

- keep migration runs idempotent where practical
- do not add inline comments to `export` commands
- prefer small, restartable execution steps
