-- =====================================================
-- AgroVision Pro - Database Migration V2
-- Crop Types and Video Management Tables
-- =====================================================

-- Create crop types reference table
CREATE TABLE crop_types (
    code VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150),
    category VARCHAR(50), -- FRUIT, VEGETABLE, GRAIN, etc.
    growth_cycle_days INTEGER,
    optimal_conditions JSONB, -- temperature, humidity, soil_ph, etc.
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Crop types indexes
CREATE INDEX idx_crop_types_category ON crop_types(category);
CREATE INDEX idx_crop_types_name ON crop_types(name);
