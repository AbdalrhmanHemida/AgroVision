from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # Database Configuration
    postgres_server: str = "localhost"
    postgres_user: str = "agrovision"
    postgres_password: str = "0106800"
    postgres_db: str = "agrovision_dev"
    
    # Redis Configuration
    redis_url: str = "redis://localhost:6379"
    
    # Security
    secret_key: str = "dev-secret-key"
    api_secret_key: str = "dev-api-secret-change-in-production"
    
    # Environment
    environment: str = "development"
    node_env: str = "development"
    
    # AI/ML Configuration
    model_path: str = "./models"
    processing_timeout: int = 300
    max_concurrent_jobs: int = 3
    
    # File Upload Configuration
    upload_dir: str = "./uploads"
    max_file_size: int = 500000000
    allowed_video_formats: str = "mp4,avi,mov,mkv"
    
    # Logging
    log_level: str = "info"
    
    # Optional External Services
    weather_api_key: Optional[str] = None
    sentry_dsn: Optional[str] = None
    
    # AWS Configuration (Optional)
    aws_access_key_id: Optional[str] = None
    aws_secret_access_key: Optional[str] = None
    aws_region: str = "us-east-1"
    aws_s3_bucket: Optional[str] = None
    
    class Config:
        env_file = ".env"
        extra = "ignore"  # Allow extra environment variables without error

settings = Settings()
