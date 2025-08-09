# 🧪 AgroVision Backend Testing Guide

## 🚀 Quick Start

### 1. Run the Application

```bash
# Navigate to backend directory
cd backend

# Run the application (requires PostgreSQL database)
./gradlew bootRun
```

### 2. Test Endpoints

Once the application is running on `http://localhost:8080`, you can test these endpoints:

#### Health Check
```bash
curl http://localhost:8080/api/test/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "service": "AgroVision Backend",
  "timestamp": "2024-01-15T10:30:00",
  "version": "1.0.0"
}
```

#### Hello Endpoint
```bash
curl http://localhost:8080/api/test/hello
```

**Expected Response:**
```json
{
  "message": "Hello from AgroVision Backend!",
  "framework": "Spring Boot",
  "language": "Java"
}
```

#### Ping Endpoint
```bash
curl http://localhost:8080/api/test/ping
```

**Expected Response:**
```
pong
```

## 🛠️ Development

### Available Endpoints

| Endpoint | Method | Description | Response |
|----------|--------|-------------|----------|
| `/api/test/health` | GET | Health check with service info | JSON |
| `/api/test/hello` | GET | Simple hello message | JSON |
| `/api/test/ping` | GET | Simple ping-pong | Text |

### Database Requirements

- PostgreSQL database running on `localhost:5432`
- Database name: `agrovision`
- Username: `postgres`
- Password: `0106800`

### Running Tests

```bash
# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests TestControllerTest
```

## 🔧 Troubleshooting

### Port Already in Use
If port 8080 is already in use, you can change it:

```bash
./gradlew bootRun --args='--server.port=8081'
```

### Database Connection Issues
If you don't have PostgreSQL running, make sure to:

1. Install PostgreSQL
2. Create database: `createdb agrovision`
3. Or update the database configuration in `application.properties`

### Build Issues
Clean and rebuild:

```bash
./gradlew clean build
```

## 📝 Logs

Check application logs for debugging:

```bash
# Follow logs in real-time
tail -f logs/application.log

# Or view in console when running with gradle
./gradlew bootRun --debug
``` 