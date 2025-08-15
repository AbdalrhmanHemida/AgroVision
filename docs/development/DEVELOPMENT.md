# AgroVision Pro - Development Guide

## 🚀 Quick Start

AgroVision Pro supports **two development approaches**:

### 🎯 Choose Your Development Mode

```bash
# Main launcher - choose between Docker or Direct
./dev.sh

# Or run directly:
./dev-docker.sh    # Docker development
./dev-direct.sh    # Direct development
```

## 🐳 Docker Development (Not Ready Yet)

**Best for:** Team consistency, isolated environments, easy setup

**Advantages:**
- ✅ Isolated environment
- ✅ Consistent across systems
- ✅ Easy setup and teardown
- ✅ No local dependency conflicts

**Requirements:** Docker & Docker Compose

```bash
./scripts/docker-dev.sh
```

## 🖥️ Direct Development

**Best for:** Faster development cycle, debugging, performance

**Advantages:**
- ✅ Faster startup and hot reload
- ✅ Direct access to logs and debugging
- ✅ Native performance
- ✅ Easy IDE integration

**Requirements:** Local dependencies installed

```bash
./scripts/dev-direct.sh
```

### Direct Development Prerequisites

| Service | Requirements |
|---------|-------------|
| **Backend** | Java 21+, Gradle |
| **Frontend** | Node.js 18+, pnpm |
| **AI Service** | Python 3.11+, pip |
| **Database** | PostgreSQL 12+ |
| **Cache** | Redis 6+ |

The script will check and guide you through installing missing dependencies.

### Direct Development Features

The direct development script (`dev-direct.sh`) provides:

1. **🔍 Prerequisites Check** - Automatically detects missing dependencies
2. **🛠️ Service Setup** - Sets up Python venv, installs dependencies
3. **🗄️ Infrastructure Management** - Starts PostgreSQL and Redis
4. **🗃️ Database Setup** - Creates database if needed
5. **🚀 Multi-Terminal Launch** - Opens each service in its own terminal
6. **📊 Status Monitoring** - Real-time service health checks

### Manual Direct Development Commands

If you prefer running services manually:

```bash
# 1. Start infrastructure
sudo systemctl start postgresql redis-server

# 2. Backend (Terminal 1) - Multiple options:
cd backend
# Option A: Gradle (if working)
./gradlew bootRun
# Option B: VS Code green button

# 3. Frontend (Terminal 2)
cd frontend
pnpm install  # if first time
pnpm run dev

# 4. AI Service (Terminal 3)
cd ai-service
source .venv/bin/activate
uvicorn app.main:app --reload
```

### Available Services

| Service | Port | Description | URL |
|---------|------|-------------|-----|
| Frontend | 5173 | React/Vite App | http://localhost:5173 |
| Backend | 8080 | Spring Boot API | http://localhost:8080 |
| AI Service | 8000 | Python/FastAPI | http://localhost:8000 |
| PostgreSQL | 5432 | Database | localhost:5432 |

## 🛠️ Development Script Features

### Main Options
1. **🚀 Start all services (use cache)** - Quick start with existing images
2. **🔄 Rebuild and start (no cache)** - Full rebuild and start
3. **📊 View logs** - Monitor service logs in real-time
4. **🛑 Stop all containers** - Clean shutdown

### Database Operations
- **🔗 Connect to PostgreSQL terminal** - Direct database access
- **📊 Show database status** - Check connection and info
- **🌐 Open PgAdmin** - Web-based database management
- **🔄 Restart database** - Reset database service
- **📋 Show database logs** - Monitor database activity

### Service Management
- **🚀 Start specific service** - Launch individual services
- **🛑 Stop specific service** - Stop individual services
- **🔄 Restart specific service** - Restart individual services
- **🔧 Rebuild specific service** - Rebuild and restart services
- **📊 Show all services status** - Detailed status overview

### Additional Features
- **🔍 Health check** - Verify all services are responding
- **🌐 Open service URLs** - Quick access to all web interfaces

## 🗄️ Database Access

### PostgreSQL Terminal Access

```bash
# Via development script (option 5 -> 1)
./dev.sh

# Or directly
docker-compose -f docker-compose.dev.yml exec postgres psql -U agrovision -d agrovision_dev
```

### Database Connection Details
- **Host:** localhost
- **Port:** 5433
- **Database:** agrovision_dev
- **Username:** agrovision
- **Password:** 0106800

## 🔧 Manual Commands

If you prefer manual control:

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up -d

# Start specific service
docker-compose -f docker-compose.dev.yml up -d backend

# View logs
docker-compose -f docker-compose.dev.yml logs -f backend

# Stop all services
docker-compose -f docker-compose.dev.yml down

# Rebuild specific service
docker-compose -f docker-compose.dev.yml build --no-cache backend
docker-compose -f docker-compose.dev.yml up -d backend
```

## 🏗️ Architecture

```
AgroVision/
├── frontend/          # React/Vite application
├── backend/           # Spring Boot API
├── ai-service/        # Python/FastAPI AI service
├── uploads/           # Shared file storage
├── scripts/           # Development scripts
└── docker-compose.dev.yml  # Development environment
```

## 🔍 Health Monitoring

The development script includes built-in health checks for:
- PostgreSQL database connectivity
- Redis cache connectivity
- Backend API health endpoint
- Frontend application availability
- AI Service health endpoint

## 📝 Environment Configuration

The script automatically handles:
- `.env` file creation from `.env.example`
- Database initialization and schema management
- Service dependency ordering
- Volume mounting for shared uploads

## 🚨 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 3000, 8080, 8000, 5433, 6379, 5050, 8081 are available
2. **Permission issues**: Run `chmod +x dev.sh scripts/docker-dev.sh`
3. **Docker issues**: Ensure Docker and Docker Compose are running
4. **Database connection**: Use the health check option to verify connectivity

#### **Backend Gradle Wrapper Issues**

If you encounter this error when running the backend:

```bash
Error: Unable to access jarfile /path/to/backend/gradle/wrapper/gradle-wrapper.jar
```

**Solution**: The `gradle-wrapper.jar` file is missing. This is automatically fixed by the development script, but you can also fix it manually:

```bash
cd backend
curl -L -o gradle/wrapper/gradle-wrapper.jar https://github.com/gradle/gradle/raw/v8.14.3/gradle/wrapper/gradle-wrapper.jar
./gradlew --version  # Verify it works
```

#### **Java Version Issues**
Ensure you have Java 21 installed:

```bash
java -version  # Should show version 21.x.x
```

#### **Port Conflicts**
If services fail to start due to port conflicts:

```bash
# Check what's using the ports
lsof -i :8080  # Backend
lsof -i :5173  # Frontend  
lsof -i :8000  # AI Service
```

#### **Database Connection Issues**

If the backend can't connect to PostgreSQL:

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start if needed
sudo systemctl start postgresql
```

### Reset Everything

```bash
# Stop all containers and remove volumes
docker-compose -f docker-compose.dev.yml down -v

# Remove all images
docker-compose -f docker-compose.dev.yml down --rmi all

# Start fresh
./dev.sh
```
