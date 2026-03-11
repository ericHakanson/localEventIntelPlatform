BEGIN;

INSERT INTO entity_type (entity_type_key, description)
VALUES
    ('property', 'Physical property or parcel-backed site'),
    ('address', 'Normalized address entity'),
    ('parcel', 'Parcel-level entity'),
    ('person', 'Person-level entity when legally retained'),
    ('business', 'Registered or operating business'),
    ('organization', 'Non-person organization'),
    ('professional_practice', 'Practice or office-based professional entity'),
    ('office_location', 'Customer office location used for targeting'),
    ('service_area', 'Geographic service-area abstraction')
ON CONFLICT (entity_type_key) DO NOTHING;

INSERT INTO event_type (event_type_key, description)
VALUES
    ('home_sale_closed', 'Closed residential or commercial property sale'),
    ('building_permit_issued', 'Building permit issuance'),
    ('solar_permit_issued', 'Solar permit issuance'),
    ('remodel_permit_issued', 'Remodel or renovation permit issuance'),
    ('business_registered', 'Business registration or formation event'),
    ('business_license_issued', 'Business license issuance'),
    ('probate_filed', 'Probate or estate-related filing'),
    ('professional_office_opened', 'Professional office or practice opening')
ON CONFLICT (event_type_key) DO NOTHING;

INSERT INTO signal_type (signal_type_key, description)
VALUES
    ('new_mover_home_services', 'Lead derived from a move or home sale for local service providers'),
    ('permit_contractor_lead', 'Lead derived from a permit event for contractors and adjacent services'),
    ('new_business_b2b_lead', 'Lead derived from business registration or licensing activity'),
    ('healthcare_referral_target', 'Reference or event-derived target for local healthcare outreach'),
    ('investor_probate_opportunity', 'Lead derived from probate or estate-related activity')
ON CONFLICT (signal_type_key) DO NOTHING;

INSERT INTO delivery_channel (channel_key, description)
VALUES
    ('postgrid', 'Direct-mail fulfillment through PostGrid'),
    ('google_sheets', 'Lead delivery through Google Sheets export or sync'),
    ('email_export', 'Email-ready export for Mailchimp or SendGrid workflows'),
    ('sms_export', 'SMS-ready export for Twilio workflows')
ON CONFLICT (channel_key) DO NOTHING;

INSERT INTO vertical (vertical_key, name, description)
VALUES
    ('home_services', 'Home Services', 'Contractors, landscapers, remodelers, and related local services'),
    ('healthcare_practices', 'Healthcare Practices', 'Local practices and adjacent healthcare outreach buyers'),
    ('legal_services', 'Legal Services', 'Attorneys and legal-service firms'),
    ('accounting_b2b', 'Accounting And B2B Services', 'Accountants and other business-service providers'),
    ('real_estate_investor', 'Real Estate Investor', 'Investor or investor-adjacent service buyers')
ON CONFLICT (vertical_key) DO NOTHING;

INSERT INTO score_component (component_key, name, description)
VALUES
    ('recency', 'Recency', 'Weighting based on event or record freshness'),
    ('event_value', 'Event Value', 'Estimated economic value associated with the event'),
    ('source_confidence', 'Source Confidence', 'Confidence in source quality and parser accuracy'),
    ('geo_fit', 'Geographic Fit', 'Fit to office location and service area'),
    ('industry_fit', 'Industry Fit', 'Fit between the signal and target vertical'),
    ('entity_quality', 'Entity Quality', 'Confidence in resolved entity quality'),
    ('customer_fit', 'Customer Fit', 'Customer-specific match overlay')
ON CONFLICT (component_key) DO NOTHING;

INSERT INTO source_system (source_key, name, category)
VALUES
    ('zillow', 'Zillow', 'web'),
    ('redfin', 'Redfin', 'web'),
    ('municipal_permits', 'Municipal Permits', 'public_record'),
    ('business_registries', 'Business Registries', 'public_record'),
    ('provider_rosters', 'Provider Rosters', 'reference')
ON CONFLICT (source_key) DO NOTHING;

COMMIT;
