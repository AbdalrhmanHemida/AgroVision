#!/bin/bash
# ===========================================
# AgroVision Pro - Direct Development Manager
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1  # Port is in use
    else
        return 0  # Port is available
    fi
}

# Check prerequisites
check_prerequisites() {
    print_header "🔍 Checking Prerequisites"
    
    local missing_deps=()
    
    # Check Java
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$java_version" -ge 21 ]; then
            print_status "Java $java_version found"
        else
            print_error "Java 21+ required (found: $java_version)"
            missing_deps+=("java21")
        fi
    else
        print_error "Java not found"
        missing_deps+=("java21")
    fi
    
    # Check Node.js
    if command_exists node; then
        local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -ge 18 ]; then
            print_status "Node.js $(node -v) found"
        else
            print_error "Node.js 18+ required (found: $(node -v))"
            missing_deps+=("nodejs")
        fi
    else
        print_error "Node.js not found"
        missing_deps+=("nodejs")
    fi
    
    # Check pnpm
    if command_exists pnpm; then
        print_status "pnpm $(pnpm -v) found"
    else
        print_error "pnpm not found"
        missing_deps+=("pnpm")
    fi
    
    # Check Python
    if command_exists python3; then
        local python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)"; then
            print_status "Python $python_version found"
        else
            print_error "Python 3.11+ required (found: $python_version)"
            missing_deps+=("python3.11")
        fi
    else
        print_error "Python3 not found"
        missing_deps+=("python3")
    fi
    
    # Check pip
    if command_exists pip3; then
        print_status "pip3 found"
    else
        print_error "pip3 not found"
        missing_deps+=("pip3")
    fi
    
    # Check PostgreSQL
    if command_exists psql; then
        print_status "PostgreSQL client found"
        # Check if PostgreSQL server is running
        if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
            print_status "PostgreSQL server is running"
        else
            print_warning "PostgreSQL server not running on localhost:5432"
            print_info "You'll need to start PostgreSQL server manually"
        fi
    else
        print_error "PostgreSQL not found"
        missing_deps+=("postgresql")
    fi
    
    # Check Redis
    if command_exists redis-cli; then
        print_status "Redis client found"
        # Check if Redis server is running
        if redis-cli ping >/dev/null 2>&1; then
            print_status "Redis server is running"
        else
            print_warning "Redis server not running on localhost:6379"
            print_info "You'll need to start Redis server manually"
        fi
    else
        print_error "Redis not found"
        missing_deps+=("redis")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Installation commands:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                java21)
                    echo "  • Java 21: sudo apt install openjdk-21-jdk (Ubuntu/Debian)"
                    ;;
                nodejs)
                    echo "  • Node.js: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
                    ;;
                pnpm)
                    echo "  • pnpm: npm install -g pnpm"
                    ;;
                python3*)
                    echo "  • Python 3.11+: sudo apt install python3.11 python3.11-venv python3.11-dev"
                    ;;
                pip3)
                    echo "  • pip3: sudo apt install python3-pip"
                    ;;
                postgresql)
                    echo "  • PostgreSQL: sudo apt install postgresql postgresql-contrib"
                    ;;
                redis)
                    echo "  • Redis: sudo apt install redis-server"
                    ;;
            esac
        done
        echo ""
        return 1
    fi
    
    print_status "All prerequisites met!"
    return 0
}

# Setup services
setup_services() {
    print_header "🛠️ Setting Up Services"
    
    # Setup Backend
    print_service "Setting up Backend (Spring Boot)..."
    if [ -f "backend/gradlew" ]; then
        chmod +x backend/gradlew
        
        # Test if gradle wrapper works
        cd backend
        if ./gradlew --version >/dev/null 2>&1; then
            print_status "Backend gradle wrapper is working - can use ./gradlew bootRun"
        else
            print_warning "Gradle wrapper has issues - attempting to fix..."
            
            # Check if gradle-wrapper.jar is missing
            if [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then
                print_info "Downloading missing gradle-wrapper.jar..."
                if curl -L -o gradle/wrapper/gradle-wrapper.jar https://github.com/gradle/gradle/raw/v8.14.3/gradle/wrapper/gradle-wrapper.jar >/dev/null 2>&1; then
                    print_status "gradle-wrapper.jar downloaded successfully"
                    
                    # Test again
                    if ./gradlew --version >/dev/null 2>&1; then
                        print_status "Backend gradle wrapper is now working - can use ./gradlew bootRun"
                    else
                        print_warning "Gradle wrapper still has issues after fix attempt"
                        print_info "You can still run the backend through VS Code or your direct Java command"
                    fi
                else
                    print_error "Failed to download gradle-wrapper.jar"
                    print_info "You can still run the backend through VS Code or your direct Java command"
                fi
            else
                print_warning "Gradle wrapper has issues but gradle-wrapper.jar exists"
                print_info "You can still run the backend through VS Code or your direct Java command"
            fi
        fi
        cd ..
    else
        print_warning "Backend gradle wrapper not found"
        print_info "Make sure you can run the backend through your IDE"
    fi
    
    # Setup Frontend
    print_service "Setting up Frontend (React)..."
    if [ -f "frontend/package.json" ]; then
        cd frontend
        # Check if node_modules is properly populated (not just empty .vite-temp)
        if [ ! -d "node_modules" ] || [ ! -f "node_modules/.pnpm/lock.yaml" ] && [ ! -f "node_modules/vite/bin/vite.js" ]; then
            print_info "Installing frontend dependencies..."
            # Remove potentially corrupted node_modules
            rm -rf node_modules
            pnpm install
        else
            print_status "Frontend dependencies already installed"
        fi
        cd ..
        print_status "Frontend dependencies ready"
    else
        print_error "Frontend package.json not found"
        return 1
    fi
    
    # Setup AI Service
    print_service "Setting up AI Service (Python)..."
    if [ -f "ai-service/requirements.txt" ]; then
        cd ai-service
        # Check for existing venv (either .venv or venv)
        if [ -d ".venv" ]; then
            print_status "Found existing .venv directory"
            VENV_DIR=".venv"
        elif [ -d "venv" ]; then
            print_status "Found existing venv directory"
            VENV_DIR="venv"
        else
            print_info "Creating Python virtual environment..."
            python3 -m venv .venv
            VENV_DIR=".venv"
        fi
        
        print_info "Activating virtual environment and installing dependencies..."
        source $VENV_DIR/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
        deactivate
        cd ..
        print_status "AI Service dependencies ready"
    else
        print_error "AI Service requirements.txt not found"
        return 1
    fi
    
    # Create uploads directory if it doesn't exist
    if [ ! -d "uploads" ]; then
        mkdir -p uploads
        print_status "Created uploads directory"
    fi
    
    print_status "All services set up successfully!"
}

# Check service status
check_service_status() {
    print_header "📊 Service Status"
    
    # Check PostgreSQL
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        print_status "PostgreSQL: Running (localhost:5432)"
    else
        print_error "PostgreSQL: Not running"
    fi
    
    # Check Redis
    if redis-cli ping >/dev/null 2>&1; then
        print_status "Redis: Running (localhost:6379)"
    else
        print_error "Redis: Not running"
    fi
    
    # Check ports
    local ports=(5173 8080 8000)
    local services=("Frontend" "Backend" "AI Service")
    
    for i in "${!ports[@]}"; do
        if check_port "${ports[$i]}"; then
            print_info "${services[$i]}: Port ${ports[$i]} available"
        else
            print_warning "${services[$i]}: Port ${ports[$i]} in use"
        fi
    done
}

# Start infrastructure services
start_infrastructure() {
    print_header "🗄️ Starting Infrastructure Services"
    
    # Start PostgreSQL
    print_service "Starting PostgreSQL..."
    if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        print_info "Starting PostgreSQL service..."
        sudo systemctl start postgresql || {
            print_error "Failed to start PostgreSQL. Please start it manually:"
            echo "  sudo systemctl start postgresql"
            echo "  or"
            echo "  sudo service postgresql start"
        }
    else
        print_status "PostgreSQL already running"
    fi
    
    # Start Redis
    print_service "Starting Redis..."
    if ! redis-cli ping >/dev/null 2>&1; then
        print_info "Starting Redis service..."
        sudo systemctl start redis-server || sudo systemctl start redis || {
            print_error "Failed to start Redis. Please start it manually:"
            echo "  sudo systemctl start redis-server"
            echo "  or"
            echo "  sudo service redis-server start"
            echo "  or"
            echo "  redis-server"
        }
    else
        print_status "Redis already running"
    fi
    
    # Wait a moment for services to start
    sleep 2
    
    # Verify services
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        print_status "PostgreSQL is ready"
    else
        print_error "PostgreSQL failed to start"
    fi
    
    if redis-cli ping >/dev/null 2>&1; then
        print_status "Redis is ready"
    else
        print_error "Redis failed to start"
    fi
}

# Create database if not exists
setup_database() {
    print_header "🗄️ Setting Up Database"
    
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        # Check if database exists
        if psql -h localhost -U postgres -lqt | cut -d \| -f 1 | grep -qw agrovision; then
            print_status "Database 'agrovision' already exists"
        else
            print_info "Creating database 'agrovision'..."
            createdb -h localhost -U postgres agrovision || {
                print_error "Failed to create database. Please create it manually:"
                echo "  createdb -h localhost -U postgres agrovision"
                echo "  or connect to PostgreSQL and run: CREATE DATABASE agrovision;"
            }
        fi
        
        # Check and fix backend configuration for direct development
        print_info "Checking backend database configuration..."
        local backend_config="backend/src/main/resources/application.properties"
        if grep -q "postgres:5432" "$backend_config"; then
            print_warning "Backend configured for Docker mode - fixing for direct development..."
            sed -i 's|spring.datasource.url=jdbc:postgresql://postgres:5432/agrovision_dev|spring.datasource.url=jdbc:postgresql://localhost:5432/agrovision|g' "$backend_config"
            sed -i 's|spring.datasource.username=agrovision|spring.datasource.username=postgres|g' "$backend_config"
            print_status "Backend configuration updated for direct development"
        else
            print_status "Backend configuration is correct for direct development"
        fi
    else
        print_error "PostgreSQL is not running. Cannot set up database."
    fi
}

# Generate run commands
generate_run_commands() {
    print_header "🚀 Service Run Commands"
    
    echo "To run services individually in separate terminals:"
    echo ""
    
    print_service "1. Backend (Spring Boot):"
    echo "   cd backend && ./gradlew bootRun"
    echo "   URL: http://localhost:8080"
    echo ""
    
    print_service "2. Frontend (React/Vite):"
    echo "   cd frontend && pnpm run dev"
    echo "   URL: http://localhost:3000"
    echo ""
    
    print_service "3. AI Service (Python/FastAPI):"
    echo "   cd ai-service && source .venv/bin/activate && uvicorn app.main:app --reload"
    echo "   URL: http://localhost:8000"
    echo ""
    
    print_info "Infrastructure services (should be running):"
    echo "   • PostgreSQL: localhost:5432"
    echo "   • Redis: localhost:6379"
}

# Check and free ports if needed
check_and_free_ports() {
    print_header "🔍 Checking Ports"
    
    local ports_in_use=()
    
    # Check each port
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
        ports_in_use+=("3000 (Frontend)")
    fi
    
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        ports_in_use+=("8080 (Backend)")
    fi
    
    if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
        ports_in_use+=("8000 (AI Service)")
    fi
    
    if [ ${#ports_in_use[@]} -gt 0 ]; then
        print_warning "Ports in use: ${ports_in_use[*]}"
        echo ""
        print_info "This might be from Docker containers or previous runs."
        read -p "Stop Docker containers and free ports? (y/N): " STOP_DOCKER
        
        if [[ "$STOP_DOCKER" =~ ^[Yy]$ ]]; then
            print_info "Stopping Docker containers..."
            docker-compose -f docker-compose.dev.yml down >/dev/null 2>&1 || true
            docker-compose -f docker-compose.yml down >/dev/null 2>&1 || true
            sleep 2
            print_status "Docker containers stopped"
        else
            print_warning "Proceeding with ports in use - services may fail to start"
        fi
    else
        print_status "All ports are available"
    fi
}

# Launch services in new terminals
launch_services() {
    print_header "🚀 Launching Services in New Terminals"
    
    # Check ports first
    check_and_free_ports
    
    # Get the current directory
    local current_dir=$(pwd)
    
    # Check if we can open new terminals
    if command_exists gnome-terminal; then
        TERMINAL_CMD="gnome-terminal"
    elif command_exists xterm; then
        TERMINAL_CMD="xterm"
    elif command_exists konsole; then
        TERMINAL_CMD="konsole"
    else
        print_error "No supported terminal emulator found"
        print_info "Please run the services manually in separate terminals"
        generate_run_commands
        return 1
    fi
    
    print_info "Opening terminals for each service..."
    
    # Detect the correct venv directory for AI service
    local ai_venv_dir=".venv"
    if [ -d "$current_dir/ai-service/venv" ]; then
        ai_venv_dir="venv"
    fi

    # Use the working gradlew bootRun command
    local backend_cmd="./gradlew bootRun"

    # Launch services
    if [ "$TERMINAL_CMD" = "gnome-terminal" ]; then
        gnome-terminal --title="AgroVision Backend" --working-directory="$current_dir/backend" -- bash -c "$backend_cmd; exec bash" &
        gnome-terminal --title="AgroVision Frontend" --working-directory="$current_dir/frontend" -- bash -c "pnpm run dev; exec bash" &
        gnome-terminal --title="AgroVision AI Service" --working-directory="$current_dir/ai-service" -- bash -c "source $ai_venv_dir/bin/activate && uvicorn app.main:app --reload; exec bash" &
    elif [ "$TERMINAL_CMD" = "konsole" ]; then
        konsole --new-tab --title="Backend" --workdir="$current_dir/backend" -e bash -c "$backend_cmd; exec bash" &
        konsole --new-tab --title="Frontend" --workdir="$current_dir/frontend" -e bash -c "pnpm run dev; exec bash" &
        konsole --new-tab --title="AI Service" --workdir="$current_dir/ai-service" -e bash -c "source $ai_venv_dir/bin/activate && uvicorn app.main:app --reload; exec bash" &
    else
        xterm -title "Backend" -e "cd $current_dir/backend && $backend_cmd; exec bash" &
        xterm -title "Frontend" -e "cd $current_dir/frontend && pnpm run dev; exec bash" &
        xterm -title "AI Service" -e "cd $current_dir/ai-service && source $ai_venv_dir/bin/activate && uvicorn app.main:app --reload; exec bash" &
    fi
    
    print_status "Services launched in separate terminals"
    
    sleep 2
    
    echo ""
    print_info "Services should be starting in separate terminals:"
    echo "   • Backend: http://localhost:8080 (./gradlew bootRun)"
    echo "   • Frontend: http://localhost:5173/"
    echo "   • AI Service: http://localhost:8000"
    echo ""
    print_warning "It may take a few moments for all services to fully start"
}

# Launch services with database terminal
launch_services_with_database() {
    print_header "🚀 Launching Services + Database Terminal"
    
    # First launch all services
    launch_services
    
    sleep 3  # Give services time to start
    
    # Check if PostgreSQL is running
    if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        print_warning "PostgreSQL is not running. Starting infrastructure first..."
        start_infrastructure
        sleep 2
    fi
    
    # Ask if user wants database terminal
    echo ""
    read -p "🗄️ Do you want to open a PostgreSQL terminal? (y/N): " OPEN_DB
    
    if [[ "$OPEN_DB" =~ ^[Yy]$ ]]; then
        print_info "Opening PostgreSQL terminal..."
        
        # Launch database terminal
        if [ "$TERMINAL_CMD" = "gnome-terminal" ]; then
            gnome-terminal --title="PostgreSQL Database" -- bash -c "echo 'Connecting to PostgreSQL...'; echo 'Password: 0106800'; psql -h localhost -U postgres -d agrovision; exec bash" &
        elif [ "$TERMINAL_CMD" = "konsole" ]; then
            konsole --new-tab --title="PostgreSQL" -e bash -c "echo 'Connecting to PostgreSQL...'; echo 'Password: 0106800'; psql -h localhost -U postgres -d agrovision; exec bash" &
        else
            xterm -title "PostgreSQL" -e "echo 'Connecting to PostgreSQL...'; echo 'Password: 0106800'; psql -h localhost -U postgres -d agrovision; exec bash" &
        fi
        
        print_status "Database terminal launched"
        echo ""
        print_info "All terminals launched:"
        echo "   • Backend: http://localhost:8080"
        echo "   • Frontend: http://localhost:5173/"
        echo "   • AI Service: http://localhost:8000"
        echo "   • Database: PostgreSQL terminal (password: 0106800)"
    else
        print_info "Database terminal skipped - use option 10 to connect later"
    fi
}

# Main menu
main_menu() {
    clear
    echo -e "${BLUE}"
    echo "=============================================="
    echo "🖥️  AgroVision Pro - Direct Development Mode"
    echo "=============================================="
    echo -e "${NC}"
    
    echo "📋 Setup & Prerequisites:"
    echo "1) 🔍 Check prerequisites"
    echo "2) 🛠️  Setup services"
    echo "3) 🗄️  Start infrastructure (PostgreSQL, Redis)"
    echo "4) 🗃️  Setup database"
    echo ""
    echo "🚀 Run Services:"
    echo "5) 📊 Check service status"
    echo "6) 🚀 Launch all services (new terminals)"
    echo "7) 🚀 Launch all services + database terminal"
    echo "8) 🎯 Launch frontend & AI only"
    echo "9) 📝 Show run commands"
    echo "10) 🗄️ Connect to PostgreSQL terminal"
    echo ""
    echo "0) 👋 Exit"
    echo ""
    read -p "👉 Choose an option [0-10]: " OPTION

    case $OPTION in
        1)
            check_prerequisites
            read -p "Press Enter to continue..."
            main_menu
            ;;
        2)
            if check_prerequisites; then
                setup_services
            fi
            read -p "Press Enter to continue..."
            main_menu
            ;;
        3)
            start_infrastructure
            read -p "Press Enter to continue..."
            main_menu
            ;;
        4)
            setup_database
            read -p "Press Enter to continue..."
            main_menu
            ;;
        5)
            check_service_status
            read -p "Press Enter to continue..."
            main_menu
            ;;
        6)
            if check_prerequisites; then
                launch_services
                read -p "Press Enter to continue..."
            fi
            main_menu
            ;;
        7)
            if check_prerequisites; then
                launch_services_with_database
                read -p "Press Enter to continue..."
            fi
            main_menu
            ;;
        8)
            if check_prerequisites; then
                launch_frontend_and_ai
                read -p "Press Enter to continue..."
            fi
            main_menu
            ;;
        9)
            generate_run_commands
            read -p "Press Enter to continue..."
            main_menu
            ;;
        10)
            connect_to_postgres
            read -p "Press Enter to continue..."
            main_menu
            ;;
        0)
            echo "👋 Exiting."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            read -p "Press Enter to continue..."
            main_menu
            ;;
    esac
}

# Launch only frontend and AI service (backend runs manually)
launch_frontend_and_ai() {
    print_header "🎯 Launching Frontend & AI Service"
    
    # Check ports first
    check_and_free_ports
    
    # Get the current directory
    local current_dir=$(pwd)
    
    # Check if we can open new terminals
    if command_exists gnome-terminal; then
        TERMINAL_CMD="gnome-terminal"
    elif command_exists xterm; then
        TERMINAL_CMD="xterm"
    elif command_exists konsole; then
        TERMINAL_CMD="konsole"
    else
        print_error "No supported terminal emulator found"
        print_info "Please run the services manually:"
        echo ""
        echo "Frontend: cd frontend && pnpm run dev"
        echo "AI Service: cd ai-service && source .venv/bin/activate && uvicorn app.main:app --reload"
        return 1
    fi
    
    # Detect the correct venv directory for AI service
    local ai_venv_dir=".venv"
    if [ -d "$current_dir/ai-service/venv" ]; then
        ai_venv_dir="venv"
    fi
    
    print_info "Launching Frontend and AI Service in separate terminals..."
    print_info "Backend can be started manually with: cd backend && ./gradlew bootRun"
    
    # Launch services
    if [ "$TERMINAL_CMD" = "gnome-terminal" ]; then
        gnome-terminal --title="AgroVision Frontend" --working-directory="$current_dir/frontend" -- bash -c "pnpm run dev; exec bash" &
        gnome-terminal --title="AgroVision AI Service" --working-directory="$current_dir/ai-service" -- bash -c "source $ai_venv_dir/bin/activate && uvicorn app.main:app --reload; exec bash" &
    elif [ "$TERMINAL_CMD" = "konsole" ]; then
        konsole --new-tab --title="Frontend" --workdir="$current_dir/frontend" -e bash -c "pnpm run dev; exec bash" &
        konsole --new-tab --title="AI Service" --workdir="$current_dir/ai-service" -e bash -c "source $ai_venv_dir/bin/activate && uvicorn app.main:app --reload; exec bash" &
    else
        xterm -title "Frontend" -e "cd $current_dir/frontend && pnpm run dev; exec bash" &
        xterm -title "AI Service" -e "cd $current_dir/ai-service && source $ai_venv_dir/bin/activate && uvicorn app.main:app --reload; exec bash" &
    fi
    
    print_status "Frontend and AI Service launched in separate terminals"
    
    sleep 2
    
    echo ""
    print_info "Services launching:"
    echo "   • Frontend: http://localhost:5173/ (terminal launched)"
    echo "   • AI Service: http://localhost:8000 (terminal launched)"
    echo ""
    print_info "Backend: Start manually with"
    echo "   • cd backend && ./gradlew bootRun"
    echo "   • URL: http://localhost:8080"
    echo ""
    print_info "Once all services are running, your development environment will be ready!"
}

# Connect to PostgreSQL terminal
connect_to_postgres() {
    print_header "🗄️ Connecting to PostgreSQL Database"
    
    # Check if PostgreSQL is running
    if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        print_error "PostgreSQL is not running on localhost:5432"
        print_info "Please start PostgreSQL first:"
        echo "  • Option 3: Start infrastructure services"
        echo "  • Or manually: sudo systemctl start postgresql"
        return 1
    fi
    
    print_status "PostgreSQL is running"
    print_info "Connecting to database 'agrovision'"
    print_info "Username: postgres"
    print_warning "You will be prompted for password: 0106800"
    echo ""
    print_info "Available commands once connected:"
    echo "  • \\l          - List databases"
    echo "  • \\dt         - List tables"  
    echo "  • \\d [table]  - Describe table"
    echo "  • \\q          - Quit"
    echo ""
    
    # Connect to PostgreSQL
    psql -h localhost -U postgres -d agrovision
    
    print_info "Disconnected from PostgreSQL"
}

# Start the script
main_menu
