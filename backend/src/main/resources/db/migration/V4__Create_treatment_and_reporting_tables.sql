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

-- Create recommendations table for treatment suggestions
CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_id UUID NOT NULL REFERENCES analyses(id) ON DELETE CASCADE,
    treatment_code VARCHAR(50) NOT NULL REFERENCES treatments(code),
    urgency_level VARCHAR(20) NOT NULL 
        CHECK (urgency_level IN ('IMMEDIATE', 'URGENT', 'MODERATE', 'MONITOR')),
    priority_rank INTEGER NOT NULL CHECK (priority_rank >= 1),
    estimated_cost DECIMAL(10,2),
    potential_savings DECIMAL(10,2),
    roi_percentage DECIMAL(5,2), -- Return on Investment
    application_timing VARCHAR(200),
    application_notes TEXT,
    confidence_score DECIMAL(5,4) CHECK (confidence_score >= 0 AND confidence_score <= 1),
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

-- Recommendations table indexes
CREATE INDEX idx_recommendations_analysis_id ON recommendations(analysis_id);
CREATE INDEX idx_recommendations_treatment_code ON recommendations(treatment_code);
CREATE INDEX idx_recommendations_urgency_level ON recommendations(urgency_level);
CREATE INDEX idx_recommendations_priority_rank ON recommendations(priority_rank);
CREATE INDEX idx_recommendations_roi ON recommendations(roi_percentage);
