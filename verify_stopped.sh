#!/bin/bash

# Verify Services Are Stopped Script

echo "🔍 Verifying all services are stopped..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check docker-compose status
echo "1️⃣  Checking docker-compose status..."
COMPOSE_OUTPUT=$(docker-compose ps 2>&1)
if echo "$COMPOSE_OUTPUT" | grep -q "no configuration file provided"; then
    echo -e "${YELLOW}⚠️  Not in project directory${NC}"
elif echo "$COMPOSE_OUTPUT" | grep -qE "telemetry-api|kafka|prometheus|grafana"; then
    echo -e "${RED}❌ Services are still running!${NC}"
    docker-compose ps
else
    echo -e "${GREEN}✅ No services running (docker-compose)${NC}"
fi
echo ""

# Check running containers
echo "2️⃣  Checking running containers..."
RUNNING=$(docker ps --format "{{.Names}}" | grep -E "telemetry-api|kafka-consumer|prometheus|alertmanager|grafana|kafka|zookeeper" | wc -l | tr -d ' ')
if [ "$RUNNING" -eq 0 ]; then
    echo -e "${GREEN}✅ No project containers running${NC}"
else
    echo -e "${RED}❌ Found $RUNNING running container(s):${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "telemetry-api|kafka-consumer|prometheus|alertmanager|grafana|kafka|zookeeper"
fi
echo ""

# Check ports
echo "3️⃣  Checking if ports are free..."
PORTS=(8000 3000 9090 9093 9092 2181)
PORT_NAMES=("Telemetry API" "Grafana" "Prometheus" "Alertmanager" "Kafka" "Zookeeper")
ALL_FREE=true

for i in "${!PORTS[@]}"; do
    PORT=${PORTS[$i]}
    NAME=${PORT_NAMES[$i]}
    
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo -e "${RED}❌ Port $PORT ($NAME) is in use${NC}"
        ALL_FREE=false
    else
        echo -e "${GREEN}✅ Port $PORT ($NAME) is free${NC}"
    fi
done
echo ""

# Check network
echo "4️⃣  Checking Docker network..."
if docker network ls | grep -q "kafkaautotool_telemetry-network"; then
    echo -e "${YELLOW}⚠️  Network still exists (containers might be stopped but not removed)${NC}"
else
    echo -e "${GREEN}✅ Network removed${NC}"
fi
echo ""

# Check volumes (data)
echo "5️⃣  Checking Docker volumes (data)..."
VOLUMES=$(docker volume ls | grep kafkaautotool | wc -l | tr -d ' ')
if [ "$VOLUMES" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $VOLUMES volume(s) - Data is preserved${NC}"
    docker volume ls | grep kafkaautotool
else
    echo -e "${YELLOW}⚠️  No volumes found - Data was removed${NC}"
fi
echo ""

# Summary
echo "=========================================="
echo "📊 VERIFICATION SUMMARY"
echo "=========================================="
if [ "$RUNNING" -eq 0 ] && [ "$ALL_FREE" = true ]; then
    echo -e "${GREEN}✅ All services are stopped!${NC}"
    echo ""
    echo "To start again:"
    echo "  docker-compose up -d"
else
    echo -e "${RED}❌ Some services may still be running${NC}"
    echo ""
    echo "To stop everything:"
    echo "  docker-compose down"
fi
echo ""
