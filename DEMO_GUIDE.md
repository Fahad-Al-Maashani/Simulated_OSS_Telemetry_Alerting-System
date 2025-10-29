# Demo Script Guide

## Overview

The `demo.sh` script provides an automated, interactive way to deploy and monitor the complete telemetry stack.

## Features

✅ **Colored Output** - Easy-to-read colored terminal output  
✅ **Health Checks** - Waits for all services to be healthy  
✅ **Port Verification** - Confirms services are responding  
✅ **Status Display** - Shows current metrics from all devices  
✅ **Real-time Monitoring** - Tails alert.log for live alerts  
✅ **Service URLs** - Displays all access points  

## Usage

### Start the Demo

```bash
./demo.sh
```

### What the Script Does

#### 1. Build & Start (Step 1)
- Runs `docker-compose up -d --build`
- Builds images if needed
- Starts all 7 services

#### 2. Health Checks (Step 2)
Waits for each service to become healthy:
- ✓ Zookeeper
- ✓ Kafka
- ✓ Telemetry API
- ✓ Prometheus
- ✓ Alertmanager
- ✓ Grafana

Also verifies ports are responding:
- Port 8000 (Telemetry API)
- Port 9090 (Prometheus)
- Port 9093 (Alertmanager)
- Port 3000 (Grafana)

#### 3. Service Status (Step 3)
Shows Docker container status with `docker-compose ps`

#### 4. API Status (Step 4)
- Calls `GET http://localhost:8000/status`
- Displays formatted JSON response (if `jq` installed)
- Shows current metrics for all 3 devices

#### 5. Real-time Monitoring (Step 5)
- Tails `logs/alert.log`
- Color-coded output:
  - 🔴 Red: Alerts and warnings
  - 🟢 Green: Info messages
  - ⚪ White: Other logs

### Stop Monitoring

Press `Ctrl+C` to stop tailing the log file.

The containers will continue running in the background.

## Cleanup

To stop all services:

```bash
./cleanup.sh
```

You'll be prompted:
- **Keep volumes**: Preserves Prometheus/Grafana data
- **Remove volumes**: Clean slate (data lost)

## Output Examples

### Successful Startup
```
========================================
STEP 1: Building and Starting Containers
========================================

▶ Running docker-compose up -d...
✓ Docker Compose started successfully

========================================
STEP 2: Waiting for Services to Initialize
========================================

▶ Waiting for telemetry-api to be healthy...
✓ telemetry-api is healthy
```

### API Status Display
```
========================================
STEP 4: Fetching Telemetry API Status
========================================

▶ Calling GET http://localhost:8000/status...

API Response:
{
  "timestamp": "2025-10-13T14:30:00.000000Z",
  "devices": [
    {
      "name": "Router-1",
      "cpu_usage_percent": 45.23,
      "latency_ms": 12.45,
      "packet_loss_percent": 0.87
    }
  ]
}

ℹ Device Metrics Summary:
  • Router-1: CPU=45.23%, Latency=12.45ms, PacketLoss=0.87%
  • Router-2: CPU=62.10%, Latency=89.32ms, PacketLoss=1.23%
  • Router-3: CPU=38.90%, Latency=156.78ms, PacketLoss=3.45%
```

### Alert Monitoring
```
========================================
STEP 5: Monitoring Real-Time Alerts
========================================

ℹ Watching logs/alert.log for alerts...
⚠ Press Ctrl+C to stop monitoring

▶ Monitoring alert.log (Kafka Consumer alerts)...
----------------------------------------
2025-10-13 14:30:15 - [ALERT] CPU_HIGH | Device: Router-2 | Value: 85.5 | ...
2025-10-13 14:30:20 - [ALERT] LATENCY_HIGH | Device: Router-3 | Value: 320.1 | ...
```

## Requirements

### Required
- Docker and Docker Compose
- Bash shell

### Optional (for enhanced output)
- `jq` - For formatted JSON display
- `nc` (netcat) - For port checking (usually pre-installed)

### Install jq (optional)
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

## Troubleshooting

### Services Not Becoming Healthy
- Wait longer (can take 60+ seconds on first run)
- Check logs: `docker-compose logs <service-name>`
- Verify Docker resources (CPU/Memory)

### Port Already in Use
```bash
# Check what's using the port
lsof -i :8000

# Stop conflicting service or change ports in docker-compose.yml
```

### No Alerts Appearing
- Alerts only fire when thresholds are exceeded
- Kafka Consumer: Immediate alerts
- Prometheus: Requires 1 minute of sustained condition
- Check if metrics are being generated: `curl http://localhost:8000/status`

### Script Permissions
```bash
chmod +x demo.sh cleanup.sh
```

## Advanced Usage

### Run Without Building
If images are already built:
```bash
docker-compose up -d
tail -f logs/alert.log
```

### View Specific Service Logs
```bash
docker-compose logs -f telemetry-api
docker-compose logs -f kafka-consumer
docker-compose logs -f prometheus
```

### Manual Health Check
```bash
docker inspect --format='{{.State.Health.Status}}' telemetry-api
```

## Color Legend

The script uses colors for better readability:

- 🔵 **Blue** - Informational messages
- 🟢 **Green** - Success messages
- 🟡 **Yellow** - Warnings
- 🔴 **Red** - Errors
- 🟣 **Magenta** - Step indicators
- 🔷 **Cyan** - Headers

## Tips

1. **First Run**: Takes longer due to image downloads and builds
2. **Subsequent Runs**: Much faster with cached images
3. **Monitor Multiple Terminals**: Run demo.sh in one, view Grafana in browser
4. **Test Alerts**: Wait for random metrics to exceed thresholds naturally
5. **Force Alerts**: Modify thresholds in `alert_rules.yml` to trigger faster

## Next Steps After Demo

1. Open Grafana dashboard: http://localhost:3000/d/telemetry-dashboard
2. View Prometheus alerts: http://localhost:9090/alerts
3. Check Alertmanager: http://localhost:9093
4. Explore API docs: http://localhost:8000/docs
5. Query Prometheus: `curl 'http://localhost:9090/api/v1/query?query=device_cpu_usage'`
