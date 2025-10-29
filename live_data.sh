#!/bin/bash

# Live Data Viewer - Shows streaming telemetry data
# Press Ctrl+C to stop

echo "🚀 Starting Live Telemetry Data Stream..."
echo ""
sleep 1

counter=1
while true; do
    clear
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo "                    📊 LIVE TELEMETRY DATA STREAM 📊"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔄 Update #$counter | ⏰ $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "────────────────────────────────────────────────────────────────────────────────"
    
    # Fetch and display data
    response=$(curl -s http://localhost:8000/status)
    
    if [ $? -eq 0 ]; then
        echo "$response" | python3 -m json.tool
        echo ""
        echo "────────────────────────────────────────────────────────────────────────────────"
        echo "✅ Data is flowing! Updates every 2 seconds"
        echo "💡 Open Grafana: http://localhost:3000/d/telemetry-dashboard"
        echo "🔑 Login: admin / admin"
    else
        echo "❌ Cannot connect to API. Is the service running?"
        echo "Run: docker-compose ps"
    fi
    
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo "Press Ctrl+C to stop"
    echo ""
    
    counter=$((counter + 1))
    sleep 2
done
