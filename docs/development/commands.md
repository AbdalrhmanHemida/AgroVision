# AgroVision - Commands Reference

This document contains all the essential commands for developing and managing the AgroVision agricultural intelligence platform.

## 🚀 Quick Start

Choose your development approach:

### Option A: Direct Development (Recommended)

```bash
# Use the automated development launcher
./dev.sh
```

### Option B: Manual Development

```bash
# Start services manually in separate terminals:
cd backend && ./gradlew bootRun     # Terminal 1: Spring Boot backend
cd frontend && pnpm dev             # Terminal 2: React frontend  
cd ai-service && source .venv/bin/activate && uvicorn app.main:app --reload # Terminal 3: FastAPI AI service

# Optional: Database terminal
psql -h localhost -U postgres -d agrovision  # Password: 0106800
```

## 📦 Package Management (pnpm)

### Backend (Spring Boot + Gradle)

```bash
cd backend

# Run application in development
./gradlew bootRun

# Build JAR file
./gradlew build

# Clean and build
./gradlew clean build

# Run tests
./gradlew test

# Run application with specific profile
./gradlew bootRun --args='--spring.profiles.active=dev'

# Generate dependency report
./gradlew dependencies

# Check for dependency updates
./gradlew dependencyUpdates

# Create bootable JAR
./gradlew bootJar

# Run with JVM debugging
./gradlew bootRun --debug-jvm
```

## 🐳 Docker Commands

### Basic Operations

```bash
# Start all services
docker-compose up -d

# Start with build
docker-compose up -d --build

# Start full development stack in Docker
docker-compose --profile dev up -d

# Stop all services
docker-compose down

# Stop and remove volumes (reset data)
docker-compose down -v

# Restart specific service
docker-compose restart <service-name>

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f <service-name>

# Enter container shell
docker-compose exec <service-name> bash

# List running containers
docker-compose ps

# Pull latest images
docker-compose pull
```

### Development Tools

```bash
# Start with development tools (PgAdmin, Redis Commander)
docker-compose --profile tools up -d

# Stop development tools
docker-compose --profile tools down
```

### Individual Services

```bash
# Start only database services
docker-compose up -d postgres redis

# Start specific service
docker-compose up -d <service-name>

# Rebuild specific service
docker-compose build <service-name>
docker-compose build frontend
docker-compose build backend
docker-compose build ai-service

# Scale service (if needed)
docker-compose up -d --scale <service-name>=2
```

---

### 🐳 Docker Compose Commands (Simple Format)

* **Start all services (detached mode):**
  `docker-compose -f docker-compose.dev.yml up -d`

* **Stop all running services:**
  `docker-compose -f docker-compose.dev.yml down`

* **Build or rebuild services:**
  `docker-compose -f docker-compose.dev.yml build`

* **Rebuild + restart everything (after code changes):**
  `docker-compose -f docker-compose.dev.yml up --build -d`

* **Remove everything (containers, networks, volumes, images):**
  `docker-compose -f docker-compose.dev.yml down --volumes --rmi all`

* **View logs of all services:**
  `docker-compose -f docker-compose.dev.yml logs -f`

* **Run a shell in a specific service (e.g. frontend):**
  `docker-compose -f docker-compose.dev.yml exec frontend sh`

---

## 🗄️ Database Management

### Spring Boot + Flyway Commands

```bash
cd backend

# Database migrations are automatically applied on startup
# Migration files location: src/main/resources/db/migration/

# Create new migration file (manual)
# Format: V{version}__{description}.sql
# Example: V001__Create_users_table.sql

# Force migration on startup (development only)
./gradlew bootRun --args='--spring.flyway.clean-disabled=false'

# Check migration status via Spring Boot Actuator
curl http://localhost:8080/actuator/flyway

# View database schema info
curl http://localhost:8080/actuator/health/db
```

### Direct Database Access

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U agrovision -d agrovision_dev

# Backup database
docker-compose exec postgres pg_dump -U agrovision agrovision_dev > backup.sql

# Restore database
docker-compose exec -T postgres psql -U agrovision -d agrovision_dev < backup.sql

# Create new database
docker-compose exec postgres createdb -U agrovision <new-db-name>

# Drop database
docker-compose exec postgres dropdb -U agrovision <db-name>

# Check connections
SELECT * FROM pg_stat_activity;

# Check database size
SELECT pg_size_pretty(pg_database_size('agrovision_dev'));
```

## 🗄️ Database Operations

### **Schema Changes & Migrations (Spring Boot + Flyway)**

```bash
# 1. Create new migration file in backend/src/main/resources/db/migration/
# Format: V{version}__{description}.sql
# Example: V002__Add_farm_table.sql

# 2. Write SQL DDL commands in the migration file
# Example content:
# CREATE TABLE farms (
#     id BIGSERIAL PRIMARY KEY,
#     name VARCHAR(255) NOT NULL,
#     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );

# 3. Restart Spring Boot application to apply migrations
cd backend
./gradlew bootRun

# 4. Verify migration was applied
curl http://localhost:8080/actuator/flyway
```

### **Database Reset (Development Only)**

```bash
# Stop application and reset database
docker-compose restart postgres

# Flyway will re-apply all migrations on next startup
cd backend
./gradlew bootRun
```


## 🤖 AI Service Management

### Python Environment

```bash
cd ai-service

# Install dependencies
pip install -r requirements.txt

# Install development dependencies
pip install -r requirements-dev.txt

# Install new Python packages
pip install <package-name>
pip freeze > requirements.txt  # Update requirements

# Start development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Start production server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

# Run tests
pytest

# Run with coverage
pytest --cov=app

# Format code
black app/

# Sort imports
isort app/

# Lint code
flake8 app/
```

### Container Operations

```bash
# Build AI service image
docker-compose build ai-service

# Enter AI service container
docker-compose exec ai-service bash

# View AI service logs
docker-compose logs -f ai-service

# Restart AI service
docker-compose restart ai-service
```


## 🚨 Emergency Procedures

### **Complete Reset (Nuclear Option)**

```bash
# Stop everything
docker-compose down -v
pkill -f "pnpm dev"
pkill -f "gradlew bootRun"
pkill -f "uvicorn"

# Clean everything
rm -rf frontend/node_modules
cd frontend && pnpm install

# Clean Gradle build
cd backend
./gradlew clean

# Clean Python cache
cd ai-service
find . -type d -name __pycache__ -delete
pip install -r requirements.txt --force-reinstall

# Restart from scratch
docker-compose up -d postgres redis pgadmin redis-commander
```

### **Service-Specific Reset**

```bash
# Frontend only (React + Vite)
cd frontend && rm -rf node_modules dist && pnpm install && pnpm dev

# Backend only (Spring Boot)
cd backend && ./gradlew clean && ./gradlew bootRun

# AI Service only (FastAPI)
cd ai-service && pip install -r requirements.txt --force-reinstall && uvicorn app.main:app --reload

# Database only (PostgreSQL + Flyway)
docker-compose restart postgres
# Migrations will be re-applied automatically on next backend startup
```

## 🔧 Debugging & Monitoring

### Log Management

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f ai-service

# View logs with timestamps
docker-compose logs -f -t

# View last N lines
docker-compose logs --tail=50 <service-name>

# Save logs to file
docker-compose logs > application.log
```