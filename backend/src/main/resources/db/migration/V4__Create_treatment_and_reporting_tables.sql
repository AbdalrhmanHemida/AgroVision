-- =====================================================
-- AgroVision Pro - Database Migration V4
-- Treatment, Recommendations, and Reporting Tables
-- =====================================================

-- Create treatments reference table
CREATE TABLE treatments (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('FUNGICIDE', 'PESTICIDE', 'ORGANIC', 'BIOLOGICAL', 'CULTURAL')),
    active_ingredients TEXT[],
    application_methods JSONB, -- spray, soil_drench, seed_treatment, etc.
    target_diseases VARCHAR(50)[], -- array of disease codes
    target_pests VARCHAR(50)[], -- array of pest codes  
    compatible_crops VARCHAR(20)[], -- array of crop_type codes
    cost_per_hectare DECIMAL(10,2),
    effectiveness_percentage INTEGER CHECK (effectiveness_percentage >= 0 AND effectiveness_percentage <= 100),
    application_frequency VARCHAR(100), -- "Every 7-14 days", "Once per season"
    pre_harvest_interval_days INTEGER, -- safety period before harvest
    safety_warnings JSONB,
    organic_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Treatments table indexes
CREATE INDEX idx_treatments_type ON treatments(type);
CREATE INDEX idx_treatments_target_diseases ON treatments USING GIN(target_diseases);
CREATE INDEX idx_treatments_compatible_crops ON treatments USING GIN(compatible_crops);
CREATE INDEX idx_treatments_organic_approved ON treatments(organic_approved);
CREATE INDEX idx_treatments_cost ON treatments(cost_per_hectare);

