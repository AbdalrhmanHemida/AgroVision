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

-- Create videos table for uploaded content
CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    duration INTEGER, -- seconds
    crop_type_code VARCHAR(20) REFERENCES crop_types(code),
    location VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    recorded_at TIMESTAMP,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'UPLOADED' 
        CHECK (status IN ('UPLOADED', 'PROCESSING', 'COMPLETED', 'FAILED', 'DELETED')),
    metadata JSONB, -- resolution, fps, codec, etc.
    
    -- Constraints
    CONSTRAINT chk_file_size CHECK (file_size > 0 AND file_size <= 524288000), -- 500MB max
    CONSTRAINT chk_duration CHECK (duration >= 10 AND duration <= 1800) -- 10 sec to 30 min
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Crop types indexes
CREATE INDEX idx_crop_types_category ON crop_types(category);
CREATE INDEX idx_crop_types_name ON crop_types(name);

-- Videos table indexes
CREATE INDEX idx_videos_user_id ON videos(user_id);
CREATE INDEX idx_videos_crop_type ON videos(crop_type_code);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_videos_uploaded_at ON videos(uploaded_at);
CREATE INDEX idx_videos_location ON videos(location);

-- =====================================================
-- SEED DATA
-- =====================================================

-- Insert common crop types
INSERT INTO crop_types (code, name, scientific_name, category, growth_cycle_days, optimal_conditions) VALUES
('TOMATO', 'Tomato', 'Solanum lycopersicum', 'FRUIT', 120, 
 '{"temperature_min": 18, "temperature_max": 27, "humidity": "60-70%", "soil_ph": "6.0-6.8"}'),
('POTATO', 'Potato', 'Solanum tuberosum', 'VEGETABLE', 90,
 '{"temperature_min": 15, "temperature_max": 20, "humidity": "80-85%", "soil_ph": "5.0-6.0"}'),
('WHEAT', 'Wheat', 'Triticum aestivum', 'GRAIN', 180,
 '{"temperature_min": 12, "temperature_max": 25, "humidity": "50-60%", "soil_ph": "6.0-7.0"}'),
('CORN', 'Corn', 'Zea mays', 'GRAIN', 140,
 '{"temperature_min": 16, "temperature_max": 35, "humidity": "50-60%", "soil_ph": "6.0-6.8"}'),
('CUCUMBER', 'Cucumber', 'Cucumis sativus', 'VEGETABLE', 60,
 '{"temperature_min": 18, "temperature_max": 24, "humidity": "60-70%", "soil_ph": "6.0-7.0"}'),
('PEPPER', 'Bell Pepper', 'Capsicum annuum', 'FRUIT', 100,
 '{"temperature_min": 21, "temperature_max": 29, "humidity": "50-70%", "soil_ph": "6.0-6.8"}'),
('LETTUCE', 'Lettuce', 'Lactuca sativa', 'VEGETABLE', 45,
 '{"temperature_min": 15, "temperature_max": 20, "humidity": "80-85%", "soil_ph": "6.0-7.0"}'),
('CARROT', 'Carrot', 'Daucus carota', 'VEGETABLE', 75,
 '{"temperature_min": 16, "temperature_max": 21, "humidity": "65-75%", "soil_ph": "6.0-6.8"}'),
('ONION', 'Onion', 'Allium cepa', 'VEGETABLE', 120,
 '{"temperature_min": 13, "temperature_max": 24, "humidity": "65-70%", "soil_ph": "6.0-7.0"}'),
('CABBAGE', 'Cabbage', 'Brassica oleracea', 'VEGETABLE', 90,
 '{"temperature_min": 15, "temperature_max": 20, "humidity": "80-90%", "soil_ph": "6.0-6.5"}');
