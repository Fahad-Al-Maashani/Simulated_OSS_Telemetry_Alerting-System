#!/bin/bash

# Setup Real-Time Streaming Dashboard
# Opens Grafana with optimal settings for streaming visualization

echo "🎬 Setting up real-time streaming dashboard..."
echo ""

# Configuration
GRAFANA_URL="http://localhost:3000"
DASHBOARD_UID="telemetry-dashboard"

# Optimal settings for streaming
TIME_RANGE="now-1m"  # Last 1 minute (faster movement)
REFRESH="2s"         # Refresh every 2 seconds
ORG_ID="1"

# Build URL with streaming parameters
STREAMING_URL="${GRAFANA_URL}/d/${DASHBOARD_UID}/network-device-telemetry?orgId=${ORG_ID}&refresh=${REFRESH}&from=${TIME_RANGE}&to=now"

echo "✅ Opening Grafana with streaming configuration:"
echo "   • Time Range: Last 1 minute (for faster movement)"
echo "   • Auto-Refresh: Every 2 seconds"
echo "   • Live Mode: Enabled"
echo ""
echo "📊 Dashboard URL:"
echo "   ${STREAMING_URL}"
echo ""
echo "💡 Tips for best streaming experience:"
echo "   1. In Grafana, click the time picker (top right)"
echo "   2. Enable 'Live' mode for continuous scrolling"
echo "   3. Try different refresh rates: 1s, 5s, 10s"
echo "   4. Use 'Last 1 minute' for faster movement"
echo "   5. Use 'Last 5 minutes' for more data history"
echo ""

# Open in browser
open "${STREAMING_URL}"

echo "✅ Dashboard opened!"
echo ""
echo "🔄 Data is streaming every 2 seconds"
echo "📈 Graphs will update in real-time"
echo ""
