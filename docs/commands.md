# AgroVision Pro - Commands Reference

This document contains all the essential commands for developing and managing the AgroVision Pro application.

## 🚀 Quick Start

Choose your development approach:

### Option A: Full Docker Development (Recommended for Production-like Environment)

```bash
# Setup and start everything in Docker
./scripts/docker-dev.sh

# Stop all services
docker-compose -f docker-compose.dev.yml down
```

### Option B: Local Development (Faster Development Experience)

```bash
# Setup local development with database in Docker
./scripts/local-dev.sh

# Start development servers in separate terminals:
cd frontend && pnpm dev     # Terminal 1
cd backend && pnpm start:dev # Terminal 2
cd ai-service && uvicorn app.main:app --reload # Terminal 3
```

### Legacy Setup (if needed)

```bash
# Run the original automated setup (has some issues)
./scripts/dev-setup.sh
```

## 📦 Package Management (pnpm)

### Frontend (Next.js)

```bash
cd frontend

# Install dependencies
pnpm install

# Add new dependency
pnpm add <package-name>

# Add development dependency
pnpm add -D <package-name>

# Remove dependency
pnpm remove <package-name>

# Update dependencies
pnpm update

# Run development server
pnpm dev

# Build for production
pnpm build

# Start production server
pnpm start

# Run linting
pnpm lint

# Run type checking
pnpm type-check
```

### Backend (NestJS)

```bash
cd backend

# Install dependencies
pnpm install

# Add new dependency
pnpm add <package-name>

# Start development server
pnpm start:dev

# Build application
pnpm build

# Start production server
pnpm start:prod

# Run tests
pnpm test

# Run e2e tests
pnpm test:e2e

# Generate new module
pnpm nest generate module <module-name>

# Generate new controller
pnpm nest generate controller <controller-name>

# Generate new service
pnpm nest generate service <service-name>
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

### Prisma Commands

```bash
cd frontend

# Initialize Prisma
pnpm prisma init

# Generate Prisma client
pnpm prisma generate

# Push schema to database
pnpm prisma db push

# Pull schema from database
pnpm prisma db pull

# Create migration
pnpm prisma migrate dev --name <migration-name>

# Deploy migrations
pnpm prisma migrate deploy

# Reset database
pnpm prisma migrate reset

# Browse database
pnpm prisma studio

# Format schema file
pnpm prisma format

# Validate schema
pnpm prisma validate
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

### **Schema Changes & Migrations**

```bash
# From frontend directory (where Prisma is configured)
cd frontend

# 1. Edit database/prisma/schema.prisma
# 2. Generate Prisma client
pnpm run db:generate

# 3. Push changes to database
pnpm run db:push

# 4. Open database UI
pnpm run db:studio
```

### **Database Reset (Development Only)**

```bash
# Reset database completely
cd frontend
pnpm run db:push --force-reset

# Seed database (if you have seeders)
pnpm run db:seed
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

## 🛠️ Development Workflow

### Code Quality

```bash
# Frontend
cd frontend
pnpm lint
pnpm type-check
pnpm build

# Backend
cd backend
pnpm lint
pnpm test
pnpm build

# AI Service
cd ai-service
black app/
isort app/
flake8 app/
pytest
```

### Testing

```bash
# Frontend tests
cd frontend
pnpm test
pnpm test:watch
pnpm test:coverage

# Backend tests
cd backend
pnpm test
pnpm test:watch
pnpm test:e2e
pnpm test:cov

# AI Service tests
cd ai-service
pytest
pytest --cov=app
pytest -v
```

## 🚨 Emergency Procedures

### **Complete Reset (Nuclear Option)**

```bash
# Stop everything
docker-compose down -v
pkill -f "pnpm dev"
pkill -f "pnpm start:dev" 
pkill -f "uvicorn"

# Clean everything
rm -rf frontend/node_modules backend/node_modules node_modules
cd frontend && pnpm install
cd backend && pnpm install
pnpm install  # Root Prisma dependencies

# Restart from scratch
./scripts/local-dev.sh
./scripts/fix-permissions.sh
```

### **Service-Specific Reset**

```bash
# Frontend only
cd frontend && rm -rf .next node_modules && pnpm install && pnpm dev

# Backend only  
cd backend && rm -rf dist node_modules && pnpm install && pnpm start:dev

# AI Service only
cd ai-service && pip install -r requirements.txt --force-reinstall && uvicorn app.main:app --reload

# Database only
docker-compose restart postgres
cd frontend && pnpm run db:push --force-reset
```

## 🔧 Debugging & Monitoring

### Health Checks

```bash
# Check service health
curl http://localhost:3000/health  # Frontend
curl http://localhost:3001/health  # Backend
curl http://localhost:8000/health  # AI Service

# Check database connection
docker-compose exec postgres pg_isready -U agrovision -d agrovision_dev

# Check Redis connection
docker-compose exec redis redis-cli ping
```

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

### Performance Monitoring

```bash
# Check container resource usage
docker stats

# Check specific container stats
docker stats <container-name>

# View container processes
docker-compose top

# Check disk usage
docker system df

# Clean up unused resources
docker system prune
```

## 🔄 CI/CD & Deployment

### Production Build

```bash
# Build all services for production
docker-compose -f docker-compose.prod.yml build

# Start production environment
docker-compose -f docker-compose.prod.yml up -d

# Health check in production
curl https://your-domain.com/health
```

### Environment Management

```bash
# Copy environment template
cp env.example .env

# Edit environment variables
nano .env

# Validate environment
docker-compose config

# Load new environment
docker-compose down && docker-compose up -d
```

## 📊 Data Management

### Backup & Restore

```bash
# Full database backup
docker-compose exec postgres pg_dumpall -U agrovision > full_backup.sql

# Single database backup
docker-compose exec postgres pg_dump -U agrovision agrovision_dev > db_backup.sql

# Restore database
docker-compose exec -T postgres psql -U agrovision -d agrovision_dev < db_backup.sql

# Backup uploads directory
tar -czf uploads_backup.tar.gz uploads/

# Restore uploads
tar -xzf uploads_backup.tar.gz
```

### Data Migration

```bash
# Create new migration
cd frontend
pnpm prisma migrate dev --name add_new_feature

# Deploy migrations to production
pnpm prisma migrate deploy

# Reset and seed database
pnpm prisma migrate reset
pnpm prisma db seed
```

## 🆘 Troubleshooting

### Common Issues

```bash
# Clear all containers and start fresh
docker-compose down -v
docker system prune -a
docker-compose up -d --build

# Fix permission issues
sudo chown -R $USER:$USER .

# Clear pnpm cache
pnpm store prune

# Clear Next.js cache
cd frontend
rm -rf .next

# Clear NestJS build
cd backend
rm -rf dist

# Restart Docker daemon (Linux)
sudo systemctl restart docker
```

### Service-Specific Troubleshooting

```bash
# Frontend issues
cd frontend
rm -rf node_modules .next
pnpm install
pnpm dev

# Backend issues
cd backend
rm -rf node_modules dist
pnpm install
pnpm build
pnpm start:dev

# Database connection issues
docker-compose restart postgres
docker-compose logs postgres

# Redis issues
docker-compose restart redis
docker-compose exec redis redis-cli ping
```

## **Permission Errors**

```bash
# Run this whenever you get permission denied errors
./scripts/fix-permissions.sh
```

## 📝 Useful Aliases

Add these to your `.bashrc` or `.zshrc`:

```bash
# AgroVision Pro aliases
alias agro-start='docker-compose up -d'
alias agro-stop='docker-compose down'
alias agro-restart='docker-compose restart'
alias agro-logs='docker-compose logs -f'
alias agro-build='docker-compose up -d --build'
alias agro-clean='docker-compose down -v && docker system prune -f'

# Service-specific aliases
alias agro-frontend='docker-compose logs -f frontend'
alias agro-backend='docker-compose logs -f backend'
alias agro-ai='docker-compose logs -f ai-service'
alias agro-db='docker-compose exec postgres psql -U agrovision -d agrovision_dev'

# Development aliases
alias agro-fe='cd frontend && pnpm dev'
alias agro-be='cd backend && pnpm start:dev'
alias agro-test='docker-compose exec backend pnpm test'
```

## 🔗 Useful URLs

- **Frontend**: <http://localhost:3000>
- **Backend API**: <http://localhost:3001>
- **AI Service**: <http://localhost:8000>
- **PgAdmin**: <http://localhost:5050> (<admin@agrovision.com> / 0106800)
- **Redis Commander**: <http://localhost:8081>
- **API Documentation**: <http://localhost:3001/api/docs>
- **GraphQL Playground**: <http://localhost:3001/graphql>
