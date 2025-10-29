#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_header "Telemetry API - Cleanup"

echo -e "${YELLOW}This will stop all containers and optionally remove volumes.${NC}"
echo ""
read -p "Remove volumes (data will be lost)? [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Stopping containers and removing volumes..."
    docker-compose down -v
    print_success "Containers stopped and volumes removed"
else
    print_info "Stopping containers (keeping volumes)..."
    docker-compose down
    print_success "Containers stopped (volumes preserved)"
fi

echo ""
print_info "To restart: ./demo.sh or docker-compose up -d"
echo ""
