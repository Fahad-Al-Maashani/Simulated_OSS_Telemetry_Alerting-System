#!/bin/bash

echo "=========================================="
echo "Starting Telemetry API with Kafka"
echo "=========================================="
echo ""

# Create logs directory if it doesn't exist
mkdir -p logs

# Start all services
echo "Starting services..."
docker-compose up -d

echo ""
echo "Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "=========================================="
echo "Services are running!"
echo "=========================================="
echo ""
echo "Access points:"
echo "  - Telemetry API: http://localhost:8000"
echo "  - API Docs: http://localhost:8000/docs"
echo "  - Prometheus: http://localhost:9090"
echo "  - Alertmanager: http://localhost:9093"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "Quick actions:"
echo "  - View Dashboard: http://localhost:3000/d/telemetry-dashboard"
echo "  - View Alerts: http://localhost:9090/alerts"
echo "  - Monitor alert logs: tail -f logs/alert.log"
echo ""
echo "View logs:"
echo "  docker-compose logs -f"
echo ""
echo "Stop services:"
echo "  docker-compose down"
echo ""
