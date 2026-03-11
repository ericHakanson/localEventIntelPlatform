BEGIN;

CREATE TABLE vertical (
    vertical_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vertical_key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE subscriber_vertical (
    subscriber_vertical_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID NOT NULL REFERENCES subscriber(subscriber_id) ON DELETE CASCADE,
    vertical_id UUID NOT NULL REFERENCES vertical(vertical_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (subscriber_id, vertical_id)
);

CREATE TABLE score_model (
    score_model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vertical_id UUID NOT NULL REFERENCES vertical(vertical_id),
    model_key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    applies_to_kind TEXT NOT NULL,
    signal_type_id UUID REFERENCES signal_type(signal_type_id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (applies_to_kind IN ('event', 'reference'))
);

CREATE TABLE score_component (
    score_component_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    component_key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE score_model_component (
    score_model_component_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    score_model_id UUID NOT NULL REFERENCES score_model(score_model_id) ON DELETE CASCADE,
    score_component_id UUID NOT NULL REFERENCES score_component(score_component_id),
    weight NUMERIC(8,4) NOT NULL,
    config JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (score_model_id, score_component_id)
);

CREATE TABLE signal_score (
    signal_score_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_id UUID NOT NULL REFERENCES signal(signal_id) ON DELETE CASCADE,
    score_model_id UUID NOT NULL REFERENCES score_model(score_model_id),
    score_component_id UUID REFERENCES score_component(score_component_id),
    score_kind TEXT NOT NULL DEFAULT 'component',
    score_value NUMERIC(8,4) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (score_kind IN ('component', 'total'))
);

CREATE TABLE industry_mapping (
    industry_mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type_id UUID REFERENCES event_type(event_type_id),
    signal_type_id UUID REFERENCES signal_type(signal_type_id),
    vertical_id UUID NOT NULL REFERENCES vertical(vertical_id),
    match_score NUMERIC(8,4) NOT NULL DEFAULT 1.0000,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (
        (event_type_id IS NOT NULL AND signal_type_id IS NULL)
        OR (event_type_id IS NULL AND signal_type_id IS NOT NULL)
    )
);

CREATE INDEX idx_subscriber_vertical_subscriber_id ON subscriber_vertical (subscriber_id);
CREATE INDEX idx_score_model_vertical_id ON score_model (vertical_id);
CREATE INDEX idx_signal_score_signal_id ON signal_score (signal_id);
CREATE INDEX idx_signal_score_score_model_id ON signal_score (score_model_id);
CREATE INDEX idx_industry_mapping_vertical_id ON industry_mapping (vertical_id);

COMMENT ON TABLE vertical IS
    'Commercial verticals used for scoring, packaging, and targeting.';

COMMENT ON TABLE score_model IS
    'Rule-based score model definitions, scoped by vertical and product shape.';

COMMENT ON TABLE signal_score IS
    'Explainable per-signal scoring outputs including component and total values.';

COMMIT;
