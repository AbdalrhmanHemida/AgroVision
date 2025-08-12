#!/bin/bash
# ===========================================
# AgroVision Pro - Development Launcher
# ===========================================

# Navigate to project root if not already there
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${BLUE}"
echo "=============================================="
echo "🚀 AgroVision Pro - Development Environment"
echo "=============================================="
echo -e "${NC}"

echo "Choose your development approach:"
echo ""
echo -e "${GREEN}1) 🐳 Docker Development${NC}"
echo "   • All services in containers"
echo "   • Isolated environment"
echo "   • Easy setup and teardown"
echo "   • Consistent across systems"
echo ""
echo -e "${GREEN}2) 🖥️  Direct Development${NC}"
echo "   • Services run directly on your machine"
echo "   • Faster development cycle"
echo "   • Direct access to logs and debugging"
echo "   • Requires local dependencies"
echo ""
echo "0) Exit"
echo ""
read -p "👉 Choose your development mode [1-2]: " CHOICE

case $CHOICE in
    1)
        echo ""
        echo "🐳 Starting Docker Development Environment..."
        exec ./scripts/docker-dev.sh
        ;;
    2)
        echo ""
        echo "🖥️  Starting Direct Development Environment..."
        exec ./scripts/dev-direct.sh
        ;;
    0)
        echo "👋 Exiting."
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac
