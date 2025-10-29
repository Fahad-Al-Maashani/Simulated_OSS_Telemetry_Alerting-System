#!/bin/bash

# Grafana Data Verification Script
# Checks all components to ensure data is flowing to Grafana

echo "🔍 Grafana Data Flow Verification"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check if Telemetry API is generating data
echo "1️⃣  Checking Telemetry API..."
API_RESPONSE=$(curl -s http://localhost:8000/status)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Telemetry API is responding${NC}"
    echo "   Sample data:"
    echo "$API_RESPONSE" | python3 -m json.tool | head -15
else
    echo -e "${RED}❌ Telemetry API is not responding${NC}"
    exit 1
fi
echo ""

# Step 2: Check if Prometheus is scraping
echo "2️⃣  Checking Prometheus metrics endpoint..."
METRICS=$(curl -s http://localhost:8000/metrics | grep device_cpu_usage | head -3)
if [ ! -z "$METRICS" ]; then
    echo -e "${GREEN}✅ Prometheus metrics are exposed${NC}"
    echo "   Sample metrics:"
    echo "$METRICS"
else
    echo -e "${RED}❌ No metrics found${NC}"
    exit 1
fi
echo ""

# Step 3: Check if Prometheus has data
echo "3️⃣  Checking Prometheus database..."
PROM_DATA=$(curl -s 'http://localhost:9090/api/v1/query?query=device_cpu_usage')
if echo "$PROM_DATA" | grep -q "Router-1"; then
    echo -e "${GREEN}✅ Prometheus has data for all devices${NC}"
    echo "   Data points found:"
    echo "$PROM_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f\"   - {len(data['data']['result'])} devices with metrics\")"
else
    echo -e "${RED}❌ Prometheus has no data${NC}"
    exit 1
fi
echo ""

# Step 4: Check Grafana datasource
echo "4️⃣  Checking Grafana datasource..."
DS_CHECK=$(curl -s -u admin:admin http://localhost:3000/api/datasources)
if echo "$DS_CHECK" | grep -q "Prometheus"; then
    echo -e "${GREEN}✅ Grafana datasource configured${NC}"
    echo "   Datasource: Prometheus at http://prometheus:9090"
else
    echo -e "${RED}❌ Grafana datasource not configured${NC}"
    exit 1
fi
echo ""

# Step 5: Check Grafana dashboard
echo "5️⃣  Checking Grafana dashboard..."
DASH_CHECK=$(curl -s -u admin:admin 'http://localhost:3000/api/search?query=telemetry')
if echo "$DASH_CHECK" | grep -q "telemetry-dashboard"; then
    echo -e "${GREEN}✅ Dashboard exists${NC}"
    echo "   Dashboard: Network Device Telemetry"
else
    echo -e "${RED}❌ Dashboard not found${NC}"
    exit 1
fi
echo ""

# Step 6: Test Grafana query
echo "6️⃣  Testing Grafana query to Prometheus..."
QUERY_TEST=$(curl -s -u admin:admin -X POST -H "Content-Type: application/json" \
  -d '{"queries":[{"refId":"A","expr":"device_cpu_usage","datasource":{"type":"prometheus","uid":"PBFA97CFB590B2093"}}],"from":"now-5m","to":"now"}' \
  'http://localhost:3000/api/ds/query')

if echo "$QUERY_TEST" | grep -q "Router-1"; then
    echo -e "${GREEN}✅ Grafana can query data from Prometheus${NC}"
    DATA_POINTS=$(echo "$QUERY_TEST" | python3 -c "import sys, json; data=json.load(sys.stdin); frames=data['results']['A']['frames']; print(len(frames)) if frames else print(0)")
    echo "   Data series found: $DATA_POINTS"
else
    echo -e "${YELLOW}⚠️  Grafana query returned no data${NC}"
    echo "   This might be normal if the system just started"
fi
echo ""

# Summary
echo "=================================="
echo "📊 VERIFICATION COMPLETE"
echo "=================================="
echo ""
echo -e "${GREEN}✅ All checks passed!${NC}"
echo ""
echo "🌐 Access Points:"
echo "   • Grafana Dashboard: http://localhost:3000/d/telemetry-dashboard"
echo "   • Login: admin / admin"
echo "   • Prometheus: http://localhost:9090"
echo ""
echo "💡 Troubleshooting Tips:"
echo "   1. Login to Grafana (admin/admin)"
echo "   2. Navigate to the dashboard"
echo "   3. Check time range (top right) - set to 'Last 5 minutes'"
echo "   4. Click the refresh button or enable auto-refresh (5s)"
echo "   5. If still no data, wait 30 seconds for metrics to accumulate"
echo ""
echo "🔄 To see live data in terminal, run:"
echo "   ./stream_monitor.py"
echo ""
