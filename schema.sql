-- ============================================================
-- AI-Based Crop Recommendation & Advisory System
-- Supabase PostgreSQL Schema
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- for GPS coordinates / map features

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE user_role AS ENUM ('farmer', 'field_worker', 'district_officer', 'super_admin');
CREATE TYPE soil_type AS ENUM ('sandy', 'silty', 'clay', 'loamy', 'peaty', 'chalky', 'char_land');
CREATE TYPE water_source AS ENUM ('rain_fed', 'canal', 'borewell', 'river', 'flood_prone', 'mixed');
CREATE TYPE alert_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE alert_status AS ENUM ('draft', 'published', 'resolved');
CREATE TYPE sync_status AS ENUM ('pending', 'synced', 'failed');
CREATE TYPE crop_cycle_status AS ENUM ('planned', 'active', 'harvested', 'abandoned');

-- ============================================================
-- USERS & ROLES
-- ============================================================

-- Core user profile (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE,
    role user_role NOT NULL DEFAULT 'farmer',
    preferred_language TEXT NOT NULL DEFAULT 'en', -- 'en', 'as' (Assamese), 'bn', 'bodo'
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- District Officers are scoped to a district
CREATE TABLE public.districts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,                  -- e.g. "Nalbari", "Kamrup", "Barpeta"
    state TEXT NOT NULL DEFAULT 'Assam',
    headquarters TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Field workers are assigned to a district and cover specific villages
CREATE TABLE public.field_workers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    district_id UUID NOT NULL REFERENCES public.districts(id),
    assigned_villages TEXT[],            -- Array of village names they cover
    employee_code TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- District officers scoped to one district
CREATE TABLE public.district_officers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    district_id UUID NOT NULL REFERENCES public.districts(id),
    designation TEXT,                    -- e.g. "District Agricultural Officer"
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- FARMER PROFILES
-- ============================================================

CREATE TABLE public.farmers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    district_id UUID REFERENCES public.districts(id),
    village TEXT NOT NULL,
    village_location GEOGRAPHY(POINT, 4326), -- GPS of village center
    total_land_bigha NUMERIC(8, 2),
    assigned_field_worker_id UUID REFERENCES public.field_workers(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- FIELDS (individual plots per farmer)
-- ============================================================

CREATE TABLE public.fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                          -- e.g. "North Plot", "Char Land"
    area_bigha NUMERIC(8, 2) NOT NULL,
    location GEOGRAPHY(POINT, 4326),             -- GPS pin dropped on field
    location_description TEXT,                   -- typed fallback if no GPS
    soil_type soil_type,
    water_source water_source,
    is_irrigated BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SOIL DATA
-- ============================================================

CREATE TABLE public.soil_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    field_id UUID NOT NULL REFERENCES public.fields(id) ON DELETE CASCADE,
    submitted_by UUID NOT NULL REFERENCES public.profiles(id), -- farmer or field worker
    submitted_on_behalf_of UUID REFERENCES public.farmers(id), -- set if field worker submitted

    -- Core NPK + pH
    nitrogen_kg_ha NUMERIC(8, 2),        -- N (kg/hectare)
    phosphorus_kg_ha NUMERIC(8, 2),      -- P
    potassium_kg_ha NUMERIC(8, 2),       -- K
    ph_level NUMERIC(4, 2),              -- e.g. 5.5 to 8.0
    organic_carbon_percent NUMERIC(5, 2),
    ec_ds_m NUMERIC(6, 3),               -- Electrical conductivity

    -- Secondary nutrients (optional)
    sulphur_ppm NUMERIC(6, 2),
    zinc_ppm NUMERIC(6, 2),
    boron_ppm NUMERIC(6, 2),

    -- Context
    season TEXT,                         -- e.g. "Kharif 2024", "Rabi 2024-25"
    sample_date DATE NOT NULL DEFAULT CURRENT_DATE,
    lab_report_url TEXT,                 -- optional uploaded scan
    notes TEXT,

    -- Offline sync tracking
    sync_status sync_status NOT NULL DEFAULT 'synced',
    local_id TEXT,                       -- client-generated ID for offline dedup

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- CROP RECOMMENDATIONS (ML model output)
-- ============================================================

CREATE TABLE public.crop_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    field_id UUID NOT NULL REFERENCES public.fields(id) ON DELETE CASCADE,
    soil_record_id UUID REFERENCES public.soil_records(id),
    generated_by UUID REFERENCES public.profiles(id), -- who triggered it
    model_version TEXT,                  -- e.g. "v1.2.0"

    -- Top K crops returned by ML model (stored as ordered JSON array)
    -- Each item: { rank, crop_name, confidence_score, sowing_month, harvest_month }
    recommended_crops JSONB NOT NULL,

    -- Season context at time of recommendation
    season TEXT,
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Farmer's selected crop from a recommendation
CREATE TABLE public.crop_selections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recommendation_id UUID NOT NULL REFERENCES public.crop_recommendations(id),
    field_id UUID NOT NULL REFERENCES public.fields(id),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id),
    crop_name TEXT NOT NULL,
    status crop_cycle_status NOT NULL DEFAULT 'planned',

    -- Economic snapshot at time of selection
    estimated_yield_kg_bigha NUMERIC(8, 2),
    estimated_input_cost_inr NUMERIC(10, 2),
    estimated_revenue_inr NUMERIC(10, 2),
    estimated_profit_inr NUMERIC(10, 2),
    economic_viability_score NUMERIC(5, 2), -- 0-100

    -- Mandi price used for calculation
    mandi_price_inr_qtl NUMERIC(8, 2),
    mandi_price_date DATE,

    sowing_date DATE,
    expected_harvest_date DATE,
    actual_harvest_date DATE,
    actual_yield_kg NUMERIC(10, 2),
    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- MANDI (MARKET) PRICES
-- ============================================================

CREATE TABLE public.mandi_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_name TEXT NOT NULL,
    district_id UUID REFERENCES public.districts(id),
    market_name TEXT,                    -- e.g. "Nagaon APMC"
    price_inr_per_quintal NUMERIC(10, 2) NOT NULL,
    price_date DATE NOT NULL DEFAULT CURRENT_DATE,
    source TEXT DEFAULT 'manual',        -- 'agmarknet', 'manual', 'api'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (crop_name, district_id, price_date)
);

-- ============================================================
-- PEST & DISEASE ALERTS
-- ============================================================

CREATE TABLE public.pest_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    district_id UUID NOT NULL REFERENCES public.districts(id),
    created_by UUID NOT NULL REFERENCES public.profiles(id),  -- field worker or officer
    published_by UUID REFERENCES public.profiles(id),         -- district officer who approved

    title TEXT NOT NULL,
    description TEXT NOT NULL,
    affected_crops TEXT[],               -- e.g. ['rice', 'mustard']
    affected_villages TEXT[],            -- specific villages or empty = district-wide
    severity alert_severity NOT NULL DEFAULT 'medium',
    status alert_status NOT NULL DEFAULT 'draft',

    -- Recommended action for farmers
    advisory TEXT,

    -- Geo bounding box (optional precision)
    affected_area GEOGRAPHY(POLYGON, 4326),

    reported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Farmer acknowledgement of an alert
CREATE TABLE public.alert_acknowledgements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id UUID NOT NULL REFERENCES public.pest_alerts(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    acknowledged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (alert_id, farmer_id)
);

-- ============================================================
-- CONVERSATIONAL AI ADVISOR (chat history)
-- ============================================================

CREATE TABLE public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    field_id UUID REFERENCES public.fields(id),          -- optional context
    language TEXT NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    -- Metadata for assistant messages
    referenced_crops TEXT[],
    referenced_alerts UUID[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- OFFLINE SYNC QUEUE
-- ============================================================

-- Tracks any record created offline that needs to be synced
CREATE TABLE public.sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID REFERENCES public.farmers(id),
    submitted_by UUID NOT NULL REFERENCES public.profiles(id),
    entity_type TEXT NOT NULL,           -- 'soil_record', 'field', 'crop_selection'
    entity_local_id TEXT NOT NULL,       -- client-side generated ID
    payload JSONB NOT NULL,              -- full record to insert/update
    sync_status sync_status NOT NULL DEFAULT 'pending',
    error_message TEXT,
    created_locally_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ML MODEL REGISTRY (Super Admin)
-- ============================================================

CREATE TABLE public.ml_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version TEXT NOT NULL UNIQUE,        -- e.g. "v1.2.0"
    description TEXT,
    model_url TEXT NOT NULL,             -- storage path in Supabase Storage
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    uploaded_by UUID REFERENCES public.profiles(id),
    activated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- AUDIT LOG (Super Admin)
-- ============================================================

CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES public.profiles(id),
    actor_role user_role,
    action TEXT NOT NULL,                -- e.g. 'publish_alert', 'activate_model', 'delete_farmer'
    entity_type TEXT,                    -- 'pest_alert', 'ml_model', 'farmer', etc.
    entity_id UUID,
    old_value JSONB,
    new_value JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_farmers_district ON public.farmers(district_id);
CREATE INDEX idx_farmers_field_worker ON public.farmers(assigned_field_worker_id);
CREATE INDEX idx_fields_farmer ON public.fields(farmer_id);
CREATE INDEX idx_soil_records_field ON public.soil_records(field_id);
CREATE INDEX idx_soil_records_season ON public.soil_records(season);
CREATE INDEX idx_soil_records_sync ON public.soil_records(sync_status);
CREATE INDEX idx_recommendations_field ON public.crop_recommendations(field_id);
CREATE INDEX idx_selections_farmer ON public.crop_selections(farmer_id);
CREATE INDEX idx_selections_status ON public.crop_selections(status);
CREATE INDEX idx_pest_alerts_district ON public.pest_alerts(district_id);
CREATE INDEX idx_pest_alerts_status ON public.pest_alerts(status);
CREATE INDEX idx_mandi_prices_crop_district ON public.mandi_prices(crop_name, district_id);
CREATE INDEX idx_chat_sessions_farmer ON public.chat_sessions(farmer_id);
CREATE INDEX idx_chat_messages_session ON public.chat_messages(session_id);
CREATE INDEX idx_audit_logs_actor ON public.audit_logs(actor_id);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
CREATE INDEX idx_sync_queue_status ON public.sync_queue(sync_status);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farmers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.soil_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crop_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crop_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pest_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read/update their own profile
CREATE POLICY "users_own_profile" ON public.profiles
    FOR ALL USING (auth.uid() = id);

-- Farmers: farmer sees only their own record
CREATE POLICY "farmer_own_record" ON public.farmers
    FOR ALL USING (profile_id = auth.uid());

-- Field workers see farmers assigned to them
CREATE POLICY "field_worker_sees_assigned_farmers" ON public.farmers
    FOR SELECT USING (
        assigned_field_worker_id IN (
            SELECT id FROM public.field_workers WHERE profile_id = auth.uid()
        )
    );

-- District officers see all farmers in their district
CREATE POLICY "officer_sees_district_farmers" ON public.farmers
    FOR SELECT USING (
        district_id IN (
            SELECT district_id FROM public.district_officers WHERE profile_id = auth.uid()
        )
    );

-- Fields: farmer owns their fields
CREATE POLICY "farmer_owns_fields" ON public.fields
    FOR ALL USING (
        farmer_id IN (SELECT id FROM public.farmers WHERE profile_id = auth.uid())
    );

-- Field workers can read/write fields for their assigned farmers
CREATE POLICY "field_worker_manages_fields" ON public.fields
    FOR ALL USING (
        farmer_id IN (
            SELECT id FROM public.farmers
            WHERE assigned_field_worker_id IN (
                SELECT id FROM public.field_workers WHERE profile_id = auth.uid()
            )
        )
    );

-- Soil records: farmer sees their own fields' soil data
CREATE POLICY "farmer_own_soil" ON public.soil_records
    FOR ALL USING (
        field_id IN (
            SELECT f.id FROM public.fields f
            JOIN public.farmers fa ON fa.id = f.farmer_id
            WHERE fa.profile_id = auth.uid()
        )
    );

-- Pest alerts: published alerts visible to all authenticated users
CREATE POLICY "published_alerts_visible" ON public.pest_alerts
    FOR SELECT USING (status = 'published');

-- District officers can manage alerts in their district
CREATE POLICY "officer_manages_alerts" ON public.pest_alerts
    FOR ALL USING (
        district_id IN (
            SELECT district_id FROM public.district_officers WHERE profile_id = auth.uid()
        )
    );

-- Chat sessions: farmer sees only their own
CREATE POLICY "farmer_own_chat" ON public.chat_sessions
    FOR ALL USING (
        farmer_id IN (SELECT id FROM public.farmers WHERE profile_id = auth.uid())
    );

-- Sync queue: user manages their own queue entries
CREATE POLICY "own_sync_queue" ON public.sync_queue
    FOR ALL USING (submitted_by = auth.uid());

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_farmers_updated BEFORE UPDATE ON public.farmers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_fields_updated BEFORE UPDATE ON public.fields
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_crop_selections_updated BEFORE UPDATE ON public.crop_selections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_pest_alerts_updated BEFORE UPDATE ON public.pest_alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_chat_sessions_updated BEFORE UPDATE ON public.chat_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to get the latest soil record for a field
CREATE OR REPLACE FUNCTION get_latest_soil_record(p_field_id UUID)
RETURNS public.soil_records AS $$
    SELECT * FROM public.soil_records
    WHERE field_id = p_field_id AND sync_status = 'synced'
    ORDER BY sample_date DESC, created_at DESC
    LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Function to get active pest alerts for a farmer's village/district
CREATE OR REPLACE FUNCTION get_alerts_for_farmer(p_farmer_id UUID)
RETURNS SETOF public.pest_alerts AS $$
    SELECT pa.* FROM public.pest_alerts pa
    JOIN public.farmers f ON f.district_id = pa.district_id
    WHERE f.id = p_farmer_id
      AND pa.status = 'published'
      AND (pa.affected_villages IS NULL
           OR pa.affected_villages = '{}'
           OR f.village = ANY(pa.affected_villages))
    ORDER BY pa.published_at DESC;
$$ LANGUAGE SQL STABLE;

-- ============================================================
-- SEED DATA — Districts (Assam)
-- ============================================================

INSERT INTO public.districts (name, state, headquarters) VALUES
    ('Kamrup Metropolitan', 'Assam', 'Guwahati'),
    ('Kamrup', 'Assam', 'Amingaon'),
    ('Nalbari', 'Assam', 'Nalbari'),
    ('Barpeta', 'Assam', 'Barpeta'),
    ('Nagaon', 'Assam', 'Nagaon'),
    ('Morigaon', 'Assam', 'Morigaon'),
    ('Sonitpur', 'Assam', 'Tezpur'),
    ('Lakhimpur', 'Assam', 'North Lakhimpur'),
    ('Dhemaji', 'Assam', 'Dhemaji'),
    ('Dibrugarh', 'Assam', 'Dibrugarh'),
    ('Sivasagar', 'Assam', 'Sivasagar'),
    ('Jorhat', 'Assam', 'Jorhat'),
    ('Golaghat', 'Assam', 'Golaghat'),
    ('Cachar', 'Assam', 'Silchar'),
    ('Kokrajhar', 'Assam', 'Kokrajhar'),
    ('Bongaigaon', 'Assam', 'Bongaigaon'),
    ('Darrang', 'Assam', 'Mangaldoi'),
    ('Udalguri', 'Assam', 'Udalguri'),
    ('Chirang', 'Assam', 'Kajalgaon'),
    ('Dhubri', 'Assam', 'Dhubri');

-- ============================================================
-- SEED DATA — Sample Mandi Prices (Assam, recent)
-- ============================================================

INSERT INTO public.mandi_prices (crop_name, market_name, price_inr_per_quintal, price_date, source)
VALUES
    ('Rice', 'Nagaon APMC', 2183, CURRENT_DATE, 'manual'),
    ('Mustard', 'Nalbari Mandi', 5450, CURRENT_DATE, 'manual'),
    ('Jute', 'Barpeta Mandi', 4200, CURRENT_DATE, 'manual'),
    ('Potato', 'Guwahati Mandi', 1800, CURRENT_DATE, 'manual'),
    ('Wheat', 'Nagaon APMC', 2275, CURRENT_DATE, 'manual'),
    ('Maize', 'Jorhat Mandi', 1962, CURRENT_DATE, 'manual'),
    ('Lentil', 'Dibrugarh Mandi', 6200, CURRENT_DATE, 'manual'),
    ('Sesame', 'Sonitpur Mandi', 8800, CURRENT_DATE, 'manual'),
    ('Boro Rice', 'Kamrup Mandi', 2200, CURRENT_DATE, 'manual'),
    ('Green Gram', 'Bongaigaon Mandi', 7100, CURRENT_DATE, 'manual');