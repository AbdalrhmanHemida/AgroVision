#!/bin/bash
# ===========================================
# AgroVision Pro - Docker Development Manager
# ===========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}$1${NC}"
}

main_menu() {
    echo -e "${BLUE}"
    echo "============================================"
    echo "🐳 AgroVision Pro - Docker Dev Environment"
    echo "============================================"
    echo -e "${NC}"
    echo "1) Start (use cache)"
    echo "2) Rebuild and start (no cache)"
    echo "3) View logs"
    echo "4) Stop containers"
    echo "0) Exit"
    read -p "👉 Choose an option [0–4]: " OPTION

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
        0)
            echo "👋 Exiting."
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Try again."
            main_menu
            ;;
    esac
}

start_dev() {
    MODE=$1

    print_header "📋 Setting up Docker development environment..."

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
        cp env.example .env
        print_status "Created .env file"
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

    # Setup database schema
    print_header "📊 Setting up database schema..."
    docker-compose -f docker-compose.dev.yml run --rm frontend sh -c "
        cd /app && 
        pnpm run db:generate:docker &&
        pnpm run db:push:docker
    "
    print_status "Database schema created"

    # Start all services
    print_header "🚀 Starting all services..."
    docker-compose -f docker-compose.dev.yml up -d

    echo ""
    print_header "🎉 Development environment ready!"
    echo ""
    echo "📱 Services:"
    echo "   • Frontend:   http://localhost:3000"
    echo "   • Backend:    http://localhost:3001"
    echo "   • AI Service: http://localhost:8000"
    echo "   • PgAdmin:    http://localhost:5050"
    echo "   • Redis UI:   http://localhost:8081"
    echo ""
    echo "🛑 To stop: docker-compose -f docker-compose.dev.yml down"
    echo "📊 To view logs: docker-compose -f docker-compose.dev.yml logs -f [service]"
    echo ""
    echo "✨ Tip: Both options are available via the main menu."
}

view_logs() {
    echo ""
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    read -p "📦 Enter service name to view logs (e.g. backend, frontend): " SERVICE
    echo ""
    docker-compose -f docker-compose.dev.yml logs -f "$SERVICE"
}

stop_containers() {
    print_header "🛑 Stopping all containers..."
    docker-compose -f docker-compose.dev.yml down
    print_status "Containers stopped"
}

# Start the script
main_menu
