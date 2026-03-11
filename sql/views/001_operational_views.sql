CREATE OR REPLACE VIEW vw_subscriber_targeting_surface AS
SELECT
    s.subscriber_id,
    s.subscriber_name,
    s.status AS subscriber_status,
    v.vertical_key,
    v.name AS vertical_name,
    ol.office_location_id,
    ol.office_name,
    ol.city,
    ol.state,
    ol.postal_code,
    ol.county,
    sa.service_area_id,
    sa.area_type,
    sa.area_value
FROM subscriber s
LEFT JOIN subscriber_vertical sv
    ON sv.subscriber_id = s.subscriber_id
LEFT JOIN vertical v
    ON v.vertical_id = sv.vertical_id
LEFT JOIN subscriber_office_location sol
    ON sol.subscriber_id = s.subscriber_id
LEFT JOIN office_location ol
    ON ol.office_location_id = sol.office_location_id
LEFT JOIN service_area sa
    ON sa.office_location_id = ol.office_location_id;

CREATE OR REPLACE VIEW vw_signal_record_origin AS
SELECT
    sg.signal_id,
    sg.signal_status,
    st.signal_type_key,
    e.event_id,
    et.event_type_key,
    rr.reference_record_id,
    rd.dataset_key AS reference_dataset_key,
    sg.created_at
FROM signal sg
JOIN signal_type st
    ON st.signal_type_id = sg.signal_type_id
LEFT JOIN event e
    ON e.event_id = sg.event_id
LEFT JOIN event_type et
    ON et.event_type_id = e.event_type_id
LEFT JOIN reference_record rr
    ON rr.reference_record_id = sg.reference_record_id
LEFT JOIN reference_dataset rd
    ON rd.reference_dataset_id = rr.reference_dataset_id;
