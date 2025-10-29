#!/bin/bash

# Simple streaming data viewer
# Shows live JSON updates every 2 seconds

echo "🌐 Starting Telemetry Data Stream..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
    clear
    echo "════════════════════════════════════════════════════════════════"
    echo "           📊 TELEMETRY DATA STREAM (Updates every 2s)"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "⏰ Timestamp: $(date)"
    echo ""
    
    # Fetch and display data
    curl -s http://localhost:8000/status | python3 -m json.tool
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "💡 Open Grafana: http://localhost:3000/d/telemetry-dashboard"
    echo "════════════════════════════════════════════════════════════════"
    
    sleep 2
done
