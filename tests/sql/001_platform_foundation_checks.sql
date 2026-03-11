DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'reference_record'
    ) THEN
        RAISE EXCEPTION 'Missing table: reference_record';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'service_area'
    ) THEN
        RAISE EXCEPTION 'Missing table: service_area';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'score_model'
    ) THEN
        RAISE EXCEPTION 'Missing table: score_model';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'signal_score'
    ) THEN
        RAISE EXCEPTION 'Missing table: signal_score';
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM entity_type WHERE entity_type_key = 'office_location'
    ) THEN
        RAISE EXCEPTION 'Missing seed: entity_type.office_location';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM event_type WHERE event_type_key = 'building_permit_issued'
    ) THEN
        RAISE EXCEPTION 'Missing seed: event_type.building_permit_issued';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM delivery_channel WHERE channel_key = 'google_sheets'
    ) THEN
        RAISE EXCEPTION 'Missing seed: delivery_channel.google_sheets';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM vertical WHERE vertical_key = 'healthcare_practices'
    ) THEN
        RAISE EXCEPTION 'Missing seed: vertical.healthcare_practices';
    END IF;
END $$;

SELECT area_type, COUNT(*) AS service_area_type_rows
FROM service_area
GROUP BY area_type
ORDER BY area_type;

SELECT vertical_key, name
FROM vertical
ORDER BY vertical_key;
