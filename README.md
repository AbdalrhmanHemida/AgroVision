# 🌱 AgroVision - Comprehensive System Guide

## 📋 Table of Contents

- [System Overview](#-system-overview)
- [Architecture & Service Connections](#-architecture--service-connections)
- [Credentials & Security](#-credentials--security)
- [Development Workflows](#-development-workflows)
- [Database Architecture](#-database-architecture)
- [Service Communication](#-service-communication)
- [Best Practices & Troubleshooting](#-best-practices--troubleshooting)
- [Getting Started](#-getting-started)

---

## 🏗️ System Overview

AgroVision is a **full-stack agricultural intelligence platform** built with modern architecture. The system consists of four main services working together to provide AI-powered agricultural insights.

### **Core Services:**

1. **Frontend** (Next.js) - User interface and client-side logic
2. **Backend** (NestJS) - API server and business logic
3. **AI Service** (FastAPI/Python) - Machine learning and AI processing
4. **Database** (PostgreSQL) - Data persistence
5. **Cache** (Redis) - Session management and caching

---

## 🔗 Architecture & Service Connections

### **Service Network Topology**

```txt
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Frontend      │     │    Backend      │     │   AI Service    │
│   (Next.js)     │     │   (NestJS)      │     │   (FastAPI)     │
│   Port: 3000    │     │   Port: 3001    │     │   Port: 8000    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐      ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │      │     Redis       │    │    PgAdmin      │
│   Port: 5433    │      │   Port: 6379    │    │   Port: 5050    │
│   (External)    │      │   (Internal)    │    │   (Tools)       │
└─────────────────┘      └─────────────────┘    └─────────────────┘
```

### **How Services Connect:**

#### **1. Frontend → Backend Communication**

- **Protocol**: HTTP/HTTPS REST API
- **URL**: `http://localhost:3001` (development)
- **Data Flow**: User actions → API calls → JSON responses

#### **2. Backend → Database Communication**

- **Protocol**: PostgreSQL connection via Prisma ORM
- **Connection String**: `postgresql://agrovision:0106800@postgres:5432/agrovision_dev`
- **Features**: Connection pooling, query optimization, migrations

#### **3. Backend → AI Service Communication**

- **Protocol**: HTTP REST API
- **URL**: `http://ai-service:8000` (internal Docker network)
- **Purpose**: Image processing, ML predictions, data analysis

#### **4. Backend → Redis Communication**

- **Protocol**: Redis protocol
- **URL**: `redis://redis:6379`
- **Usage**: Session storage, caching, job queues

#### **5. Shared Database Access**

- **Frontend**: Uses Prisma Client for type-safe database operations
- **Backend**: Primary database access layer
- **AI Service**: Direct PostgreSQL connection for ML data

---

## 🔐 Credentials & Security

### **Database Credentials**

```bash
# PostgreSQL Database
POSTGRES_DB=agrovision_dev
POSTGRES_USER=agrovision
POSTGRES_PASSWORD=0106800
DATABASE_URL=postgresql://agrovision:0106800@postgres:5432/agrovision_dev
```

### **Redis Credentials**

```bash
# Redis (No authentication in development)
REDIS_URL=redis://redis:6379
```

### **PgAdmin Credentials**

```bash
# Database Administration Tool
PGADMIN_DEFAULT_EMAIL=admin@agrovision.com
PGADMIN_DEFAULT_PASSWORD=0106800
```

### **JWT Security**

```bash
# Backend Authentication
JWT_SECRET=dev-jwt-secret-change-in-production
```

### **Where Credentials Are Stored:**

#### **Environment Files Structure:**

```
project/
├── .env                   # Root environment (database services)
├── frontend/.env.local    # Frontend-specific variables
├── backend/.env           # Backend-specific variables
├── ai-service/.env        # AI service variables
└── env.example            # Template for all environments
```

#### **Docker Compose Files:**

- `docker-compose.yml` - Production-like environment
- `docker-compose.dev.yml` - Development environment with hot reload

---

## 🚀 Development Workflows

### **Two Development Approaches:**

#### **1. Docker Development (Recommended for Full System Testing)**

```bash
# Start everything in containers
./scripts/docker-dev.sh

# Services URLs:
# Frontend:   http://localhost:3000
# Backend:    http://localhost:3001
# AI Service: http://localhost:8000
# PgAdmin:    http://localhost:5050
# Redis UI:   http://localhost:8081
```

#### **2. Local Development (Faster for Code Changes)**

```bash
# Start database services only
./scripts/local-dev.sh

# Then start apps locally:
cd frontend && pnpm dev
cd backend && pnpm start:dev
cd ai-service && source .venv/bin/activate && uvicorn app.main:app --reload

# open prisma studio (run this in the root level)
npx prisma studio --schema=database/prisma/schema.prisma
```

### **Database Operations:**

#### **Docker Environment:**

```bash
# Generate Prisma client
pnpm run db:generate:docker

# Push schema changes
pnpm run db:push:docker

# Open database studio
pnpm run db:studio:docker
```

#### **Local Environment:**

```bash
# Generate Prisma client
pnpm run db:generate:local

# Push schema changes
pnpm run db:push:local

# Open database studio
pnpm run db:studio:local
```

---

## 🗄️ Database Architecture

### **Shared Prisma Schema**

- **Location**: `database/prisma/schema.prisma`
- **Purpose**: Single source of truth for database structure
- **Access**: All services use this schema for type safety

---

## ⚠️ Best Practices & Troubleshooting

### **Common Issues & Solutions:**

#### **1. Port Conflicts**

- you can find .sh files in the `scripts` directory to free ports.

### **Monitoring & Debugging:**

- you can find commands under `docs` directory to monitor services, check logs and health.

---

### **Quick Start:**

#### **1. Clone and Setup**

```bash
git clone <repository-url>
cd agrovision
cp env.example .env
```

#### **2. Choose Development Method**

**Option A: Docker Development (Recommended)**

```bash
chmod +x scripts/docker-dev.sh
./scripts/docker-dev.sh
```

**Option B: Local Development**

```bash
chmod +x scripts/local-dev.sh
./scripts/local-dev.sh

# In separate terminals:
cd frontend && pnpm install && pnpm dev
cd backend && pnpm install && pnpm start:dev
cd ai-service && pip install -r requirements.txt && uvicorn app.main:app --reload
```

#### **3. Verify Installation**

Visit these URLs to confirm everything is working:

- Frontend: <http://localhost:3000>
- Backend: <http://localhost:3001>
- AI Service: <http://localhost:8000>
- Database UI: <http://localhost:5050>
- Redis UI: <http://localhost:8081>
