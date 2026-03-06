BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE source_system (
    source_system_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE raw_artifact (
    raw_artifact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_system_id UUID NOT NULL REFERENCES source_system(source_system_id),
    artifact_kind TEXT NOT NULL,
    storage_mode TEXT NOT NULL,
    storage_uri TEXT,
    content_hash TEXT,
    mime_type TEXT,
    byte_size BIGINT,
    fetched_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ,
    retention_class TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (storage_mode IN ('inline', 'gcs_pointer', 'external_pointer')),
    CHECK (byte_size IS NULL OR byte_size >= 0)
);

CREATE TABLE entity_type (
    entity_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type_key TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE entity (
    entity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type_id UUID NOT NULL REFERENCES entity_type(entity_type_id),
    canonical_name TEXT,
    display_name TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    confidence_score NUMERIC(5,4),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1))
);

CREATE TABLE entity_identifier (
    entity_identifier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id UUID NOT NULL REFERENCES entity(entity_id) ON DELETE CASCADE,
    identifier_type TEXT NOT NULL,
    identifier_value TEXT NOT NULL,
    source_system_id UUID REFERENCES source_system(source_system_id),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (identifier_type, identifier_value)
);

CREATE TABLE office_location (
    office_location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id UUID REFERENCES entity(entity_id),
    office_name TEXT,
    address_line_1 TEXT,
    address_line_2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    county TEXT,
    country_code TEXT NOT NULL DEFAULT 'US',
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE service_area (
    service_area_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    office_location_id UUID NOT NULL REFERENCES office_location(office_location_id) ON DELETE CASCADE,
    area_type TEXT NOT NULL,
    area_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (area_type IN ('zip', 'city', 'county'))
);

CREATE TABLE event_type (
    event_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type_key TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE event (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type_id UUID NOT NULL REFERENCES event_type(event_type_id),
    source_system_id UUID NOT NULL REFERENCES source_system(source_system_id),
    raw_artifact_id UUID REFERENCES raw_artifact(raw_artifact_id),
    event_status TEXT NOT NULL DEFAULT 'observed',
    event_date DATE,
    observed_at TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    estimated_value NUMERIC(14,2),
    confidence_score NUMERIC(5,4),
    normalization_version TEXT NOT NULL DEFAULT 'v1',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1))
);

CREATE TABLE event_entity_link (
    event_entity_link_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES event(event_id) ON DELETE CASCADE,
    entity_id UUID NOT NULL REFERENCES entity(entity_id) ON DELETE CASCADE,
    entity_role TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (event_id, entity_id, entity_role)
);

CREATE TABLE reference_dataset (
    reference_dataset_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dataset_key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    source_system_id UUID REFERENCES source_system(source_system_id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE reference_record (
    reference_record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_dataset_id UUID NOT NULL REFERENCES reference_dataset(reference_dataset_id) ON DELETE CASCADE,
    entity_id UUID REFERENCES entity(entity_id),
    raw_artifact_id UUID REFERENCES raw_artifact(raw_artifact_id),
    record_status TEXT NOT NULL DEFAULT 'active',
    effective_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE signal_type (
    signal_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_type_key TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE signal (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_type_id UUID NOT NULL REFERENCES signal_type(signal_type_id),
    event_id UUID REFERENCES event(event_id),
    reference_record_id UUID REFERENCES reference_record(reference_record_id),
    signal_status TEXT NOT NULL DEFAULT 'ready',
    lead_score NUMERIC(7,4),
    confidence_score NUMERIC(5,4),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)),
    CHECK (
        (event_id IS NOT NULL AND reference_record_id IS NULL)
        OR (event_id IS NULL AND reference_record_id IS NOT NULL)
    )
);

CREATE TABLE subscriber (
    subscriber_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_name TEXT NOT NULL,
    vertical_key TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE subscriber_office_location (
    subscriber_office_location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID NOT NULL REFERENCES subscriber(subscriber_id) ON DELETE CASCADE,
    office_location_id UUID NOT NULL REFERENCES office_location(office_location_id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (subscriber_id, office_location_id)
);

CREATE TABLE delivery_channel (
    delivery_channel_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_key TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audience_match (
    audience_match_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_id UUID NOT NULL REFERENCES signal(signal_id) ON DELETE CASCADE,
    subscriber_id UUID NOT NULL REFERENCES subscriber(subscriber_id) ON DELETE CASCADE,
    office_location_id UUID REFERENCES office_location(office_location_id),
    match_score NUMERIC(7,4),
    exclusivity_mode TEXT NOT NULL DEFAULT 'shared',
    matched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (exclusivity_mode IN ('exclusive', 'shared', 'hybrid'))
);

CREATE TABLE delivery_batch (
    delivery_batch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID NOT NULL REFERENCES subscriber(subscriber_id) ON DELETE CASCADE,
    delivery_channel_id UUID NOT NULL REFERENCES delivery_channel(delivery_channel_id),
    batch_status TEXT NOT NULL DEFAULT 'draft',
    external_batch_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE delivery_item (
    delivery_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_batch_id UUID NOT NULL REFERENCES delivery_batch(delivery_batch_id) ON DELETE CASCADE,
    audience_match_id UUID NOT NULL REFERENCES audience_match(audience_match_id) ON DELETE CASCADE,
    item_status TEXT NOT NULL DEFAULT 'pending',
    external_item_id TEXT,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (delivery_batch_id, audience_match_id)
);

CREATE INDEX idx_raw_artifact_source_system_id ON raw_artifact (source_system_id);
CREATE INDEX idx_entity_entity_type_id ON entity (entity_type_id);
CREATE INDEX idx_event_event_type_id ON event (event_type_id);
CREATE INDEX idx_event_source_system_id ON event (source_system_id);
CREATE INDEX idx_event_event_date ON event (event_date);
CREATE INDEX idx_event_entity_link_entity_id ON event_entity_link (entity_id);
CREATE INDEX idx_reference_record_dataset_id ON reference_record (reference_dataset_id);
CREATE INDEX idx_signal_signal_type_id ON signal (signal_type_id);
CREATE INDEX idx_audience_match_subscriber_id ON audience_match (subscriber_id);
CREATE INDEX idx_delivery_batch_subscriber_id ON delivery_batch (subscriber_id);

COMMENT ON TABLE reference_dataset IS
    'Reference-data products such as provider rosters that are not modeled as time-based events.';

COMMENT ON TABLE signal IS
    'Commercially useful lead or intelligence output derived from either an event or a reference record.';

COMMIT;

