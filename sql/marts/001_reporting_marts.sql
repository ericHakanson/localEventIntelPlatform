CREATE OR REPLACE VIEW mart_event_volume_by_type AS
SELECT
    e.event_date,
    et.event_type_key,
    COUNT(*) AS event_count
FROM event e
JOIN event_type et
    ON et.event_type_id = e.event_type_id
GROUP BY e.event_date, et.event_type_key;

CREATE OR REPLACE VIEW mart_source_quality AS
SELECT
    ss.source_key,
    DATE(e.created_at) AS created_date,
    COUNT(*) AS event_count,
    AVG(e.confidence_score) AS avg_event_confidence
FROM event e
JOIN source_system ss
    ON ss.source_system_id = e.source_system_id
GROUP BY ss.source_key, DATE(e.created_at);

CREATE OR REPLACE VIEW mart_signal_delivery_performance AS
SELECT
    dc.channel_key,
    DATE(db.created_at) AS batch_date,
    COUNT(DISTINCT db.delivery_batch_id) AS batch_count,
    COUNT(di.delivery_item_id) AS delivery_item_count
FROM delivery_batch db
JOIN delivery_channel dc
    ON dc.delivery_channel_id = db.delivery_channel_id
LEFT JOIN delivery_item di
    ON di.delivery_batch_id = db.delivery_batch_id
GROUP BY dc.channel_key, DATE(db.created_at);

CREATE OR REPLACE VIEW mart_subscriber_coverage AS
SELECT
    s.subscriber_id,
    s.subscriber_name,
    COUNT(DISTINCT sol.office_location_id) AS office_count,
    COUNT(DISTINCT sa.service_area_id) AS service_area_count,
    COUNT(DISTINCT sv.vertical_id) AS vertical_count
FROM subscriber s
LEFT JOIN subscriber_office_location sol
    ON sol.subscriber_id = s.subscriber_id
LEFT JOIN office_location ol
    ON ol.office_location_id = sol.office_location_id
LEFT JOIN service_area sa
    ON sa.office_location_id = ol.office_location_id
LEFT JOIN subscriber_vertical sv
    ON sv.subscriber_id = s.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name;

CREATE OR REPLACE VIEW mart_geo_market_summary AS
SELECT
    ol.state,
    ol.county,
    sa.area_type,
    sa.area_value,
    COUNT(DISTINCT sol.subscriber_id) AS subscriber_count,
    COUNT(DISTINCT ol.office_location_id) AS office_count
FROM office_location ol
LEFT JOIN service_area sa
    ON sa.office_location_id = ol.office_location_id
LEFT JOIN subscriber_office_location sol
    ON sol.office_location_id = ol.office_location_id
GROUP BY ol.state, ol.county, sa.area_type, sa.area_value;
