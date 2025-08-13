#!/bin/bash
# ===========================================
# AgroVision Pro - Docker Development Manager
# ===========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}$1${NC}"
}

print_service() {
    echo -e "${PURPLE}🔧${NC} $1"
}

# Check if service is running
check_service_status() {
    local service=$1
    if docker-compose -f docker-compose.dev.yml ps -q "$service" | grep -q .; then
        if [ "$(docker-compose -f docker-compose.dev.yml ps "$service" | grep -c "Up")" -gt 0 ]; then
            echo -e "${GREEN}●${NC} $service"
        else
            echo -e "${RED}●${NC} $service (stopped)"
        fi
    else
        echo -e "${YELLOW}●${NC} $service (not created)"
    fi
}

show_services_status() {
    print_header "📊 Services Status"
    check_service_status "postgres"
    check_service_status "redis"
    check_service_status "backend"
    check_service_status "frontend"
    check_service_status "ai-service"
    check_service_status "pgadmin"
    check_service_status "redis-commander"
    echo ""
}

main_menu() {
    clear
    echo -e "${BLUE}"
    echo "============================================"
    echo "🐳 AgroVision Pro - Docker Dev Environment"
    echo "============================================"
    echo -e "${NC}"
    
    show_services_status
    
    echo "📋 Main Options:"
    echo "1) 🚀 Start all services (use cache)"
    echo "2) 🔄 Rebuild and start (no cache)"
    echo "3) 📊 View logs"
    echo "4) 🛑 Stop all containers"
    echo ""
    echo "🔧 Individual Services:"
    echo "5) 🗄️  Database operations"
    echo "6) ⚙️  Service management"
    echo "7) 🔍 Health check"
    echo "8) 🌐 Open service URLs"
    echo ""
    echo "0) 👋 Exit"
    echo ""
    read -p "👉 Choose an option [0-8]: " OPTION

    case $OPTION in
        1)
            start_dev "cached"
            ;;
        2)
            start_dev "rebuild"
            ;;
        3)
            view_logs
            ;;
        4)
            stop_containers
            ;;
        5)
            database_menu
            ;;
        6)
            service_management_menu
            ;;
        7)
            health_check
            ;;
        8)
            open_services
            ;;
        0)
            echo "👋 Exiting."
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Try again."
            read -p "Press Enter to continue..."
            main_menu
            ;;
    esac
}

check_and_free_docker_ports() {
    print_header "🔍 Checking Port Conflicts"
    
    local ports_in_use=()
    local docker_ports=(5432 6379 8080 5173 8000)
    local service_names=("PostgreSQL" "Redis" "Backend" "Frontend" "AI Service")
    
    # Check each port
    for i in "${!docker_ports[@]}"; do
        local port=${docker_ports[$i]}
        local service=${service_names[$i]}
        
        # Use netstat as a more reliable check
        if netstat -tuln 2>/dev/null | grep -q ":$port\b" || lsof -Pi :$port -sTCP:LISTEN >/dev/null 2>&1; then
            ports_in_use+=("$port ($service)")
        fi
    done
    
    if [ ${#ports_in_use[@]} -gt 0 ]; then
        print_warning "Ports in use: ${ports_in_use[*]}"
        echo ""
        print_info "These ports are likely used by local services (PostgreSQL, Redis) or previous Docker runs."
        echo ""
        print_info "Details:"
        for i in "${!docker_ports[@]}"; do
            local port=${docker_ports[$i]}
            local service=${service_names[$i]}
            if netstat -tuln 2>/dev/null | grep -q ":$port\b" || lsof -Pi :$port -sTCP:LISTEN >/dev/null 2>&1; then
                local process_info=$(lsof -Pi :$port -sTCP:LISTEN 2>/dev/null | tail -n +2 | head -1 || echo "Unknown process")
                print_warning "  Port $port ($service): $process_info"
            fi
        done
        echo ""
        read -p "Stop local services and free ports for Docker? (y/N): " STOP_SERVICES
        
        if [[ "$STOP_SERVICES" =~ ^[Yy]$ ]]; then
            print_info "Stopping local services..."
            
            # Stop local PostgreSQL and Redis
            print_info "Stopping PostgreSQL and Redis services..."
            sudo systemctl stop postgresql redis-server redis 2>/dev/null || true
            
            # Also stop any existing Docker containers
            print_info "Stopping existing Docker containers..."
            docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
            docker-compose -f docker-compose.yml down 2>/dev/null || true
            
            # Kill any remaining processes on these ports
            print_info "Checking for remaining processes..."
            for port in "${docker_ports[@]}"; do
                local pids=$(lsof -ti :$port 2>/dev/null || true)
                if [ ! -z "$pids" ]; then
                    print_info "Killing processes on port $port: $pids"
                    echo "$pids" | xargs -r kill -9 2>/dev/null || true
                fi
            done
            
            sleep 3
            print_status "Local services stopped and Docker containers cleaned up"
            
            # Verify ports are now free
            local still_in_use=()
            for i in "${!docker_ports[@]}"; do
                local port=${docker_ports[$i]}
                if netstat -tuln 2>/dev/null | grep -q ":$port\b" || lsof -Pi :$port -sTCP:LISTEN >/dev/null 2>&1; then
                    still_in_use+=("$port")
                fi
            done
            
            if [ ${#still_in_use[@]} -gt 0 ]; then
                print_warning "Some ports are still in use: ${still_in_use[*]}"
                print_info "Docker may still fail to start. You may need to restart your system or manually kill processes."
            else
                print_status "All ports are now free"
            fi
        else
            print_warning "Proceeding with ports in use - Docker may fail to start"
            echo ""
            read -p "Continue anyway? (y/N): " CONTINUE
            if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
                print_info "Exiting. Please free the ports manually or choose to stop services."
                return 1
            fi
        fi
    else
        print_status "All Docker ports are available"
    fi
    
    return 0
}

start_dev() {
    MODE=$1

    print_header "📋 Setting up Docker development environment..."

    # Check and resolve port conflicts first
    if ! check_and_free_docker_ports; then
        return 1
    fi

    # Rebuild images if needed
    if [[ "$MODE" == "rebuild" ]]; then
        print_header "🔁 Rebuilding all images..."
        docker-compose -f docker-compose.dev.yml build
        print_status "Images rebuilt successfully"
    else
        print_info "Using cached images"
    fi

    # Ensure .env exists
    if [ ! -f .env ]; then
        if [ -f env.example ]; then
            cp env.example .env
            print_status "Created .env file from env.example"
        elif [ -f .env.example ]; then
            cp .env.example .env
            print_status "Created .env file from .env.example"
        else
            print_warning "No env.example or .env.example found - continuing without .env file"
        fi
    else
        print_info ".env file already exists"
    fi

    # Start database services first
    print_header "🗄️ Starting database services..."
    docker-compose -f docker-compose.dev.yml up -d postgres redis

    # Wait for database
    print_info "Waiting for database to be ready..."
    until docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U agrovision -d agrovision_dev > /dev/null 2>&1; do
        sleep 1
        printf "."
    done
    echo ""
    print_status "Database is ready"

    # Database schema is handled by Spring Boot + Flyway automatically
    print_info "Database schema will be managed by Spring Boot + Flyway"

    # Start all services
    print_header "🚀 Starting all services..."
    docker-compose -f docker-compose.dev.yml up -d

    echo ""
    print_header "🎉 Development environment ready!"
    echo ""
    echo "📱 Services:"
    echo "   • Frontend:   http://localhost:5173"
    echo "   • Backend:    http://localhost:8080"
    echo "   • AI Service: http://localhost:8000"
    echo "   • PgAdmin:    http://localhost:5050"
    echo "   • Redis UI:   http://localhost:8081"
    echo ""
    echo "🛑 To stop: docker-compose -f docker-compose.dev.yml down"
    echo "📊 To view logs: docker-compose -f docker-compose.dev.yml logs -f [service]"
    echo ""
    echo "✨ Tip: All options are available via the main menu."
    echo ""
    read -p "Press Enter to return to main menu..."
    main_menu
}

view_logs() {
    print_header "📊 Container Logs"
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    echo "Available services: postgres, redis, backend, frontend, ai-service, pgadmin, redis-commander"
    read -p "📦 Enter service name to view logs: " SERVICE
    
    if [ -z "$SERVICE" ]; then
        print_error "No service specified"
        read -p "Press Enter to continue..."
        main_menu
        return
    fi
    
    print_info "Showing logs for $SERVICE (Press Ctrl+C to stop)"
    echo ""
    docker-compose -f docker-compose.dev.yml logs -f "$SERVICE"
}

stop_containers() {
    print_header "🛑 Stopping all containers..."
    docker-compose -f docker-compose.dev.yml down
    print_status "Containers stopped"
    read -p "Press Enter to continue..."
    main_menu
}

database_menu() {
    clear
    print_header "🗄️ Database Operations"
    echo ""
    echo "1) 🔗 Connect to PostgreSQL terminal"
    echo "2) 📊 Show database status"
    echo "3) 🌐 Open PgAdmin (Web UI)"
    echo "4) 🔄 Restart database"
    echo "5) 📋 Show database logs"
    echo "0) ← Back to main menu"
    echo ""
    read -p "👉 Choose an option [0-5]: " DB_OPTION

    case $DB_OPTION in
        1)
            connect_to_database
            ;;
        2)
            show_database_status
            ;;
        3)
            open_pgadmin
            ;;
        4)
            restart_database
            ;;
        5)
            show_database_logs
            ;;
        0)
            main_menu
            ;;
        *)
            print_error "Invalid option"
            read -p "Press Enter to continue..."
            database_menu
            ;;
    esac
}

connect_to_database() {
    print_header "🔗 Connecting to PostgreSQL Database"
    print_info "Database: agrovision_dev"
    print_info "User: agrovision"
    echo ""
    print_warning "Type \\q to exit the database terminal"
    echo ""
    
    # Check if postgres container is running
    if ! docker-compose -f docker-compose.dev.yml ps postgres | grep -q "Up"; then
        print_error "PostgreSQL container is not running!"
        print_info "Starting PostgreSQL..."
        docker-compose -f docker-compose.dev.yml up -d postgres
        sleep 3
    fi
    
    docker-compose -f docker-compose.dev.yml exec postgres psql -U agrovision -d agrovision_dev
    
    echo ""
    read -p "Press Enter to continue..."
    database_menu
}

show_database_status() {
    print_header "📊 Database Status"
    
    if docker-compose -f docker-compose.dev.yml ps postgres | grep -q "Up"; then
        print_status "PostgreSQL is running"
        echo ""
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 5432"
        echo "  Database: agrovision_dev"
        echo "  User: agrovision"
        echo ""
        
        # Try to get database info
        if docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U agrovision -d agrovision_dev > /dev/null 2>&1; then
            print_status "Database is accepting connections"
            echo ""
            docker-compose -f docker-compose.dev.yml exec postgres psql -U agrovision -d agrovision_dev -c "SELECT version();" 2>/dev/null || true
        else
            print_warning "Database is starting up..."
        fi
    else
        print_error "PostgreSQL is not running"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    database_menu
}

open_pgadmin() {
    print_header "🌐 Opening PgAdmin"
    
    if ! docker-compose -f docker-compose.dev.yml ps pgadmin | grep -q "Up"; then
        print_info "Starting PgAdmin..."
        docker-compose -f docker-compose.dev.yml up -d pgadmin
        sleep 3
    fi
    
    print_status "PgAdmin is available at: http://localhost:5050"
    print_info "Email: admin@agrovision.com"
    print_info "Password: 0106800"
    
    # Try to open in browser (works on most systems)
    if command -v xdg-open > /dev/null; then
        xdg-open http://localhost:5050 2>/dev/null &
    elif command -v open > /dev/null; then
        open http://localhost:5050 2>/dev/null &
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    database_menu
}

restart_database() {
    print_header "🔄 Restarting Database"
    print_info "Stopping PostgreSQL..."
    docker-compose -f docker-compose.dev.yml stop postgres
    
    print_info "Starting PostgreSQL..."
    docker-compose -f docker-compose.dev.yml up -d postgres
    
    print_info "Waiting for database to be ready..."
    until docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U agrovision -d agrovision_dev > /dev/null 2>&1; do
        sleep 1
        printf "."
    done
    echo ""
    print_status "Database restarted successfully"
    
    read -p "Press Enter to continue..."
    database_menu
}

show_database_logs() {
    print_header "📋 Database Logs"
    print_info "Showing PostgreSQL logs (Press Ctrl+C to stop)"
    echo ""
    docker-compose -f docker-compose.dev.yml logs -f postgres
}

service_management_menu() {
    clear
    print_header "⚙️ Service Management"
    echo ""
    echo "1) 🚀 Start specific service"
    echo "2) 🛑 Stop specific service"
    echo "3) 🔄 Restart specific service"
    echo "4) 🔧 Rebuild specific service"
    echo "5) 📊 Show all services status"
    echo "0) ← Back to main menu"
    echo ""
    read -p "👉 Choose an option [0-5]: " SM_OPTION

    case $SM_OPTION in
        1)
            start_specific_service
            ;;
        2)
            stop_specific_service
            ;;
        3)
            restart_specific_service
            ;;
        4)
            rebuild_specific_service
            ;;
        5)
            show_detailed_status
            ;;
        0)
            main_menu
            ;;
        *)
            print_error "Invalid option"
            read -p "Press Enter to continue..."
            service_management_menu
            ;;
    esac
}

start_specific_service() {
    print_header "🚀 Start Specific Service"
    echo ""
    echo "Available services:"
    echo "  - postgres (database)"
    echo "  - redis (cache)"
    echo "  - backend (Spring Boot API)"
    echo "  - frontend (React app)"
    echo "  - ai-service (Python AI)"
    echo "  - pgadmin (database UI)"
    echo "  - redis-commander (Redis UI)"
    echo ""
    read -p "Enter service name to start: " SERVICE
    
    if [ -z "$SERVICE" ]; then
        print_error "No service specified"
    else
        print_info "Starting $SERVICE..."
        docker-compose -f docker-compose.dev.yml up -d "$SERVICE"
        print_status "$SERVICE started"
    fi
    
    read -p "Press Enter to continue..."
    service_management_menu
}

stop_specific_service() {
    print_header "🛑 Stop Specific Service"
    echo ""
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    read -p "Enter service name to stop: " SERVICE
    
    if [ -z "$SERVICE" ]; then
        print_error "No service specified"
    else
        print_info "Stopping $SERVICE..."
        docker-compose -f docker-compose.dev.yml stop "$SERVICE"
        print_status "$SERVICE stopped"
    fi
    
    read -p "Press Enter to continue..."
    service_management_menu
}

restart_specific_service() {
    print_header "🔄 Restart Specific Service"
    echo ""
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    read -p "Enter service name to restart: " SERVICE
    
    if [ -z "$SERVICE" ]; then
        print_error "No service specified"
    else
        print_info "Restarting $SERVICE..."
        docker-compose -f docker-compose.dev.yml restart "$SERVICE"
        print_status "$SERVICE restarted"
    fi
    
    read -p "Press Enter to continue..."
    service_management_menu
}

rebuild_specific_service() {
    print_header "🔧 Rebuild Specific Service"
    echo ""
    echo "Available services to rebuild:"
    echo "  - backend"
    echo "  - frontend" 
    echo "  - ai-service"
    echo ""
    read -p "Enter service name to rebuild: " SERVICE
    
    if [ -z "$SERVICE" ]; then
        print_error "No service specified"
    else
        print_info "Rebuilding $SERVICE..."
        docker-compose -f docker-compose.dev.yml build --no-cache "$SERVICE"
        print_info "Restarting $SERVICE..."
        docker-compose -f docker-compose.dev.yml up -d "$SERVICE"
        print_status "$SERVICE rebuilt and restarted"
    fi
    
    read -p "Press Enter to continue..."
    service_management_menu
}

show_detailed_status() {
    print_header "📊 Detailed Services Status"
    echo ""
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    read -p "Press Enter to continue..."
    service_management_menu
}

health_check() {
    print_header "🔍 Health Check"
    echo ""
    
    # Check database
    print_service "Checking PostgreSQL..."
    if docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U agrovision -d agrovision_dev > /dev/null 2>&1; then
        print_status "PostgreSQL: Healthy"
    else
        print_error "PostgreSQL: Not responding"
    fi
    
    # Check Redis
    print_service "Checking Redis..."
    if docker-compose -f docker-compose.dev.yml exec redis redis-cli ping > /dev/null 2>&1; then
        print_status "Redis: Healthy"
    else
        print_error "Redis: Not responding"
    fi
    
    # Check Backend API
    print_service "Checking Backend API..."
    if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
        print_status "Backend API: Healthy"
    else
        print_warning "Backend API: Not responding (may be starting up)"
    fi
    
    # Check Frontend
    print_service "Checking Frontend..."
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        print_status "Frontend: Healthy"
    else
        print_warning "Frontend: Not responding (may be starting up)"
    fi
    
    # Check AI Service
    print_service "Checking AI Service..."
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        print_status "AI Service: Healthy"
    else
        print_warning "AI Service: Not responding (may be starting up)"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

open_services() {
    print_header "🌐 Service URLs"
    echo ""
    echo "📱 Application Services:"
    echo "   • Frontend:   http://localhost:5173"
    echo "   • Backend:    http://localhost:8080"
    echo "   • AI Service: http://localhost:8000"
    echo ""
    echo "🛠️ Development Tools:"
    echo "   • PgAdmin:    http://localhost:5050"
    echo "   • Redis UI:   http://localhost:8081"
    echo ""
    echo "🔗 API Endpoints:"
    echo "   • Backend Health: http://localhost:8080/actuator/health"
    echo "   • AI Health:      http://localhost:8000/health"
    echo "   • Backend API:    http://localhost:8080/api"
    echo ""
    
    read -p "Open all services in browser? (y/N): " OPEN_ALL
    
    if [[ "$OPEN_ALL" =~ ^[Yy]$ ]]; then
        print_info "Opening services in browser..."
        
        if command -v xdg-open > /dev/null; then
            xdg-open http://localhost:5173 2>/dev/null &
            xdg-open http://localhost:8080 2>/dev/null &
            xdg-open http://localhost:8000 2>/dev/null &
            xdg-open http://localhost:5050 2>/dev/null &
            xdg-open http://localhost:8081 2>/dev/null &
        elif command -v open > /dev/null; then
            open http://localhost:5173 2>/dev/null &
            open http://localhost:8080 2>/dev/null &
            open http://localhost:8000 2>/dev/null &
            open http://localhost:5050 2>/dev/null &
            open http://localhost:8081 2>/dev/null &
        else
            print_warning "Could not detect browser command"
        fi
        
        print_status "Services opened in browser"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

# Start the script
main_menu
