#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored messages
print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_step() {
    echo -e "${MAGENTA}▶ $1${NC}"
}

# Function to check if a service is healthy
check_service() {
    local service=$1
    local max_attempts=30
    local attempt=1
    
    print_step "Waiting for $service to be healthy..."
    
    while [ $attempt -le $max_attempts ]; do
        status=$(docker inspect --format='{{.State.Health.Status}}' $service 2>/dev/null)
        
        if [ "$status" = "healthy" ]; then
            print_success "$service is healthy"
            return 0
        fi
        
        echo -ne "${YELLOW}Attempt $attempt/$max_attempts - Status: ${status:-starting}${NC}\r"
        sleep 2
        ((attempt++))
    done
    
    echo ""
    print_error "$service failed to become healthy"
    return 1
}

# Function to check if a port is responding
check_port() {
    local host=$1
    local port=$2
    local service=$3
    local max_attempts=15
    local attempt=1
    
    print_step "Checking if $service is responding on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z $host $port 2>/dev/null; then
            print_success "$service is responding on port $port"
            return 0
        fi
        
        echo -ne "${YELLOW}Attempt $attempt/$max_attempts${NC}\r"
        sleep 2
        ((attempt++))
    done
    
    echo ""
    print_warning "$service not responding on port $port (may still be starting)"
    return 1
}

# Main script starts here
clear
print_header "Telemetry API Demo - Full Stack Deployment"

# Step 1: Build and start containers
print_header "STEP 1: Building and Starting Containers"
print_step "Running docker-compose up -d..."

if docker-compose up -d --build; then
    print_success "Docker Compose started successfully"
else
    print_error "Failed to start Docker Compose"
    exit 1
fi

# Step 2: Wait for containers to initialize
print_header "STEP 2: Waiting for Services to Initialize"

print_info "This may take 30-60 seconds for all services to become healthy..."
echo ""

# Check critical services in order
services=("zookeeper" "kafka" "telemetry-api" "prometheus" "alertmanager" "grafana")

for service in "${services[@]}"; do
    check_service $service
    if [ $? -ne 0 ]; then
        print_warning "Continuing despite $service not being healthy..."
    fi
    sleep 1
done

# Additional port checks
print_step "Verifying service ports..."
check_port localhost 8000 "Telemetry API"
check_port localhost 9090 "Prometheus"
check_port localhost 9093 "Alertmanager"
check_port localhost 3000 "Grafana"

print_success "All services are up!"

# Step 3: Display service status
print_header "STEP 3: Service Status Overview"

echo -e "${WHITE}Container Status:${NC}"
docker-compose ps

# Step 4: Call FastAPI /status endpoint
print_header "STEP 4: Fetching Telemetry API Status"

print_step "Calling GET http://localhost:8000/status..."
sleep 2

if command -v jq &> /dev/null; then
    response=$(curl -s http://localhost:8000/status)
    echo -e "${WHITE}API Response:${NC}"
    echo "$response" | jq '.'
    
    # Extract and display device info
    echo ""
    print_info "Device Metrics Summary:"
    echo "$response" | jq -r '.devices[] | "  • \(.name): CPU=\(.cpu_usage_percent)%, Latency=\(.latency_ms)ms, PacketLoss=\(.packet_loss_percent)%"'
else
    curl -s http://localhost:8000/status
    print_warning "Install 'jq' for formatted JSON output"
fi

# Display access URLs
print_header "Service Access URLs"

echo -e "${WHITE}Web Interfaces:${NC}"
echo -e "  ${GREEN}•${NC} Telemetry API:    ${CYAN}http://localhost:8000${NC}"
echo -e "  ${GREEN}•${NC} API Docs:         ${CYAN}http://localhost:8000/docs${NC}"
echo -e "  ${GREEN}•${NC} Prometheus:       ${CYAN}http://localhost:9090${NC}"
echo -e "  ${GREEN}•${NC} Prometheus Alerts:${CYAN}http://localhost:9090/alerts${NC}"
echo -e "  ${GREEN}•${NC} Alertmanager:     ${CYAN}http://localhost:9093${NC}"
echo -e "  ${GREEN}•${NC} Grafana:          ${CYAN}http://localhost:3000${NC} ${YELLOW}(admin/admin)${NC}"
echo -e "  ${GREEN}•${NC} Grafana Dashboard:${CYAN}http://localhost:3000/d/telemetry-dashboard${NC}"

echo ""
echo -e "${WHITE}Alert Thresholds:${NC}"
echo -e "  ${YELLOW}•${NC} CPU > 80%"
echo -e "  ${YELLOW}•${NC} Latency > 300ms"
echo -e "  ${YELLOW}•${NC} Packet Loss > 5%"

echo ""
echo -e "${WHITE}Alert Mechanisms:${NC}"
echo -e "  ${GREEN}1.${NC} Kafka Consumer → alert.log (real-time)"
echo -e "  ${GREEN}2.${NC} Prometheus → Alertmanager → FastAPI /alert (1min persistence)"

# Create logs directory if it doesn't exist
mkdir -p logs

# Check if alert.log exists, if not create it
if [ ! -f logs/alert.log ]; then
    touch logs/alert.log
    print_info "Created logs/alert.log"
fi

# Step 5: Tail alert.log
print_header "STEP 5: Monitoring Real-Time Alerts"

print_info "Watching logs/alert.log for alerts..."
print_info "Metrics are generated every 5 seconds"
print_info "Alerts will appear when thresholds are exceeded"
echo ""
print_warning "Press Ctrl+C to stop monitoring"
echo ""

# Give services a moment to generate some data
sleep 3

# Display initial telemetry-api logs to show activity
print_step "Recent Telemetry API activity:"
docker-compose logs --tail=10 telemetry-api | grep -E "(Sent metrics|ALERT|INFO)" || echo "No recent activity"

echo ""
print_step "Monitoring alert.log (Kafka Consumer alerts)..."
echo -e "${CYAN}----------------------------------------${NC}"

# Tail the alert log with color highlighting
tail -f logs/alert.log | while read line; do
    if [[ $line == *"ALERT"* ]] || [[ $line == *"WARNING"* ]]; then
        echo -e "${RED}$line${NC}"
    elif [[ $line == *"INFO"* ]]; then
        echo -e "${GREEN}$line${NC}"
    else
        echo -e "${WHITE}$line${NC}"
    fi
done
