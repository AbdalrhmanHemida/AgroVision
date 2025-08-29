-- =====================================================
-- AgroVision Pro - Database Migration V3
-- Analysis and Disease Detection Tables
-- =====================================================

-- Create analyses table for AI processing results
CREATE TABLE analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL 
        CHECK (analysis_type IN ('DISEASE_DETECTION', 'CROP_COUNTING', 'GROWTH_STAGE', 'COMBINED')),
    status VARCHAR(20) NOT NULL DEFAULT 'PROCESSING'
        CHECK (status IN ('QUEUED', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    ai_model_version VARCHAR(20),
    confidence_score DECIMAL(5,4) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    processing_time_ms INTEGER,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT,
    results JSONB, -- Flexible storage for different analysis types
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Create crop counts table for counting analysis results
CREATE TABLE crop_counts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_id UUID NOT NULL REFERENCES analyses(id) ON DELETE CASCADE,
    total_count INTEGER NOT NULL CHECK (total_count >= 0),
    confidence_interval_lower INTEGER CHECK (confidence_interval_lower >= 0),
    confidence_interval_upper INTEGER CHECK (confidence_interval_upper >= confidence_interval_lower),
    density_per_sqm DECIMAL(8,2),
    maturity_distribution JSONB, -- {"unripe": 45, "partially_ripe": 30, "fully_ripe": 20, "overripe": 5}
    harvest_readiness_percentage DECIMAL(5,2) CHECK (harvest_readiness_percentage >= 0 AND harvest_readiness_percentage <= 100),
    estimated_yield_kg DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create growth stages table for maturity analysis results
CREATE TABLE growth_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_id UUID NOT NULL REFERENCES analyses(id) ON DELETE CASCADE,
    growth_stage VARCHAR(20) NOT NULL 
        CHECK (growth_stage IN ('SEEDLING', 'VEGETATIVE', 'FLOWERING', 'FRUITING', 'MATURE')),
    maturity_percentage DECIMAL(5,2) NOT NULL CHECK (maturity_percentage >= 0 AND maturity_percentage <= 100),
    days_to_harvest_estimate INTEGER CHECK (days_to_harvest_estimate >= 0),
    harvest_window_start DATE,
    harvest_window_end DATE,
    uniformity_index DECIMAL(3,2) CHECK (uniformity_index >= 0 AND uniformity_index <= 1),
    growth_rate VARCHAR(20) CHECK (growth_rate IN ('SLOW', 'NORMAL', 'FAST')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Analyses table indexes
CREATE INDEX idx_analyses_video_id ON analyses(video_id);
CREATE INDEX idx_analyses_analysis_type ON analyses(analysis_type);
CREATE INDEX idx_analyses_status ON analyses(status);
CREATE INDEX idx_analyses_completed_at ON analyses(completed_at);
CREATE INDEX idx_analyses_confidence_score ON analyses(confidence_score);

-- Crop counts indexes
CREATE INDEX idx_crop_counts_analysis_id ON crop_counts(analysis_id);
CREATE INDEX idx_crop_counts_total_count ON crop_counts(total_count);
CREATE INDEX idx_crop_counts_harvest_readiness ON crop_counts(harvest_readiness_percentage);

-- Growth stages indexes
CREATE INDEX idx_growth_stages_analysis_id ON growth_stages(analysis_id);
CREATE INDEX idx_growth_stages_growth_stage ON growth_stages(growth_stage);
CREATE INDEX idx_growth_stages_maturity_percentage ON growth_stages(maturity_percentage);

