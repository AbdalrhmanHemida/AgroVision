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

-- Create reports table for generated reports
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_id UUID NOT NULL REFERENCES analyses(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    report_type VARCHAR(20) NOT NULL CHECK (report_type IN ('SUMMARY', 'DETAILED', 'COMPARATIVE')),
    format VARCHAR(10) NOT NULL CHECK (format IN ('PDF', 'HTML', 'JSON')),
    title VARCHAR(255) NOT NULL,
    file_path VARCHAR(500),
    file_size BIGINT,
    generation_time_ms INTEGER,
    parameters JSONB, -- report generation parameters
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP -- for cleanup of temporary reports
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

-- Reports table indexes
CREATE INDEX idx_reports_analysis_id ON reports(analysis_id);
CREATE INDEX idx_reports_user_id ON reports(user_id);
CREATE INDEX idx_reports_report_type ON reports(report_type);
CREATE INDEX idx_reports_created_at ON reports(created_at);
CREATE INDEX idx_reports_expires_at ON reports(expires_at);

-- =====================================================
-- SEED DATA
-- =====================================================

-- Insert common treatments
INSERT INTO treatments (code, name, type, active_ingredients, target_diseases, target_pests, compatible_crops, 
                       cost_per_hectare, effectiveness_percentage, application_frequency, pre_harvest_interval_days, 
                       organic_approved, safety_warnings, application_methods) VALUES

('COPPER_FUNGICIDE', 'Copper-based Fungicide', 'FUNGICIDE', 
 ARRAY['Copper sulfate', 'Copper hydroxide'],
 ARRAY['EARLY_BLIGHT', 'LATE_BLIGHT', 'BACTERIAL_SPOT'], 
 ARRAY[]::TEXT[], 
 ARRAY['TOMATO', 'POTATO', 'PEPPER'], 
 45.00, 85, 'Every 7-14 days', 0, true,
 '{"skin_contact": "Avoid skin contact", "protective_equipment": "Wear gloves and mask", "water_sources": "Keep away from water sources"}',
 '{"spray": "Foliar spray application", "concentration": "2-3 grams per liter"}'),

('NEEM_OIL', 'Neem Oil Treatment', 'ORGANIC',
 ARRAY['Azadirachtin'],
 ARRAY['POWDERY_MILDEW', 'EARLY_BLIGHT'], 
 ARRAY['APHID_INFESTATION', 'WHITEFLY', 'SPIDER_MITES'], 
 ARRAY['CUCUMBER', 'TOMATO', 'PEPPER'], 
 30.00, 70, 'Every 5-7 days', 0, true,
 '{"application_timing": "Apply in early morning or evening", "temperature": "Avoid application in high temperatures"}',
 '{"spray": "Foliar spray", "concentration": "5-10ml per liter", "surfactant": "Add mild soap as surfactant"}'),

('BACILLUS_SUBTILIS', 'Bacillus subtilis Biofungicide', 'BIOLOGICAL',
 ARRAY['Bacillus subtilis strain QST 713'],
 ARRAY['POWDERY_MILDEW', 'EARLY_BLIGHT', 'FUSARIUM_WILT'], 
 ARRAY[]::TEXT[], 
 ARRAY['TOMATO', 'CUCUMBER', 'PEPPER'], 
 55.00, 75, 'Every 7-10 days', 0, true,
 '{"storage": "Store in cool, dry place", "mixing": "Use immediately after mixing"}',
 '{"spray": "Foliar and soil application", "soil_drench": "Root zone treatment"}'),

('CROP_ROTATION', 'Crop Rotation Practice', 'CULTURAL',
 ARRAY[]::TEXT[],
 ARRAY['EARLY_BLIGHT', 'LATE_BLIGHT', 'FUSARIUM_WILT'], 
 ARRAY[]::TEXT[], 
 ARRAY['TOMATO', 'POTATO'], 
 0.00, 60, 'Once per season', 0, true,
 '{"planning": "Plan rotation 2-3 years in advance", "family_rotation": "Avoid planting same plant family"}',
 '{"rotation_sequence": "Rotate with non-solanaceous crops", "timing": "Implement at start of growing season"}'),

('INSECTICIDAL_SOAP', 'Insecticidal Soap', 'ORGANIC',
 ARRAY['Potassium salts of fatty acids'],
 ARRAY[]::TEXT[], 
 ARRAY['APHID_INFESTATION', 'WHITEFLY', 'SPIDER_MITES'], 
 ARRAY['TOMATO', 'CUCUMBER', 'PEPPER', 'LETTUCE'], 
 25.00, 65, 'Every 3-5 days', 0, true,
 '{"phytotoxicity": "Test on small area first", "timing": "Apply in cooler parts of day"}',
 '{"spray": "Direct contact spray", "coverage": "Ensure complete coverage including undersides of leaves"}'),

('STICKY_TRAPS', 'Yellow Sticky Traps', 'CULTURAL',
 ARRAY[]::TEXT[],
 ARRAY[]::TEXT[], 
 ARRAY['WHITEFLY', 'APHID_INFESTATION'], 
 ARRAY['TOMATO', 'CUCUMBER', 'PEPPER'], 
 15.00, 50, 'Replace every 2-4 weeks', 0, true,
 '{"placement": "Place at plant canopy level", "monitoring": "Check and replace regularly"}',
 '{"installation": "Hang traps among plants", "density": "1 trap per 10 square meters"}'),

('BENEFICIAL_INSECTS', 'Beneficial Insect Release', 'BIOLOGICAL',
 ARRAY[]::TEXT[],
 ARRAY[]::TEXT[], 
 ARRAY['APHID_INFESTATION', 'WHITEFLY', 'SPIDER_MITES'], 
 ARRAY['TOMATO', 'CUCUMBER', 'PEPPER'], 
 80.00, 80, 'Once or twice per season', 0, true,
 '{"timing": "Release when pest populations are low", "environment": "Maintain suitable habitat"}',
 '{"release": "Release according to supplier instructions", "monitoring": "Monitor establishment and effectiveness"}'),

('MULCHING', 'Organic Mulching', 'CULTURAL',
 ARRAY[]::TEXT[],
 ARRAY['EARLY_BLIGHT', 'LATE_BLIGHT'], 
 ARRAY[]::TEXT[], 
 ARRAY['TOMATO', 'POTATO', 'PEPPER', 'CUCUMBER'], 
 20.00, 40, 'Once per season', 0, true,
 '{"material": "Use clean, disease-free mulch", "thickness": "Apply 5-10cm thick layer"}',
 '{"application": "Apply around plant base", "maintenance": "Maintain throughout growing season"}')
