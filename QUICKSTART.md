# Quick Start Guide

## 🚀 Start the System

### Option 1: Interactive Demo (Recommended)
```bash
./demo.sh
```
**What it does:**
- ✅ Builds and starts all 7 services
- ✅ Runs health checks
- ✅ Displays service status and URLs
- ✅ Tails alert logs in real-time
- Press `Ctrl+C` to stop monitoring (services keep running)

### Option 2: Quick Start
```bash
./start.sh
```
**What it does:**
- ✅ Starts all services
- ✅ Shows access URLs
- ✅ Returns immediately

### Option 3: Manual Start
```bash
docker-compose up -d
```
**What it does:**
- ✅ Starts all services in background
- ✅ No output, just starts

### Option 4: Start with Logs
```bash
docker-compose up
```
**What it does:**
- ✅ Starts all services
- ✅ Shows live logs from all containers
- Press `Ctrl+C` to stop

---

## 🛑 Stop the System

### Option 1: Stop & Keep Data (Recommended)
```bash
docker-compose down
```
**What it does:**
- ✅ Stops all containers
- ✅ Keeps Prometheus data
- ✅ Keeps Grafana dashboards
- ✅ Keeps alert history
- 🔄 Data persists for next start

### Option 2: Interactive Cleanup
```bash
./cleanup.sh
```
**What it does:**
- ✅ Stops all containers
- ❓ Prompts: Keep or remove data?
- Press `N` to keep data
- Press `Y` to remove everything

### Option 3: Stop & Remove Everything
```bash
docker-compose down -v
```
**What it does:**
- ✅ Stops all containers
- ❌ Deletes all data
- ❌ Deletes all volumes
- 🔄 Fresh start next time

### Option 4: Just Pause (Don't Stop)
```bash
docker-compose stop
```
**What it does:**
- ⏸️ Pauses all services
- ✅ Keeps everything in memory
- 🔄 Resume with: `docker-compose start`

---

## 🔄 Restart the System

### After `docker-compose down`:
```bash
docker-compose up -d
```
All your data is still there! ✅

### After `docker-compose stop`:
```bash
docker-compose start
```
Resumes exactly where you left off! ✅

### Restart Specific Service:
```bash
docker-compose restart telemetry-api
docker-compose restart grafana
docker-compose restart prometheus
```

### Rebuild and Restart:
```bash
docker-compose up -d --build
```

---

## 🌐 Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Telemetry API | http://localhost:8000 | - |
| API Docs (Swagger) | http://localhost:8000/docs | - |
| Prometheus | http://localhost:9090 | - |
| Alertmanager | http://localhost:9093 | - |
| Grafana | http://localhost:3000 | admin/admin |
| Kafka | localhost:9092 | - |

---

## 📊 View Live Data

### Option 1: Grafana Dashboard (Best Visualization)
```bash
open http://localhost:3000/d/telemetry-dashboard
```
**Login:** admin / admin

**You'll see:**
- 📈 CPU Usage graph (3 routers)
- 📈 Network Latency graph
- 📈 Packet Loss graph
- 🎯 Current CPU gauge

**Tips:**
- Set time range to "Last 5 minutes" (top right)
- Enable auto-refresh "5s" (top right)
- Click refresh button if no data appears

### Option 2: Live Terminal Stream
```bash
./live_data.sh
```
**Shows:**
- ✅ Real-time JSON data
- ✅ Updates every 2 seconds
- ✅ Timestamps
- Press `Ctrl+C` to stop

### Option 3: Watch Kafka Stream
```bash
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic telemetry_stream \
  --from-beginning
```
Press `Ctrl+C` to stop

### Option 4: Current Snapshot
```bash
# JSON format
curl -s http://localhost:8000/status | python3 -m json.tool

# Prometheus format
curl http://localhost:8000/metrics
```

---

## 🚨 Monitor Alerts

### Watch Alert Log (Real-time)
```bash
tail -f logs/alert.log
```
**Shows:**
- CPU alerts when > 80%
- Latency alerts when > 300ms
- Packet loss alerts when > 5%

### View Prometheus Alerts
```bash
open http://localhost:9090/alerts
```
**Shows:**
- Alert rules
- Alert states (Inactive, Pending, Firing)
- Alert history

### View Alertmanager
```bash
open http://localhost:9093
```
**Shows:**
- Active alerts
- Alert grouping
- Silence management

---

## 🔍 Check System Status

### Check All Services
```bash
docker-compose ps
```
**Shows:**
- Service names
- Status (Up/Down/Healthy)
- Ports

### Check Specific Service
```bash
docker ps | grep telemetry-api
docker ps | grep grafana
docker ps | grep prometheus
```

### View Service Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f telemetry-api
docker-compose logs -f kafka-consumer
docker-compose logs -f prometheus
docker-compose logs -f grafana

# Last 50 lines
docker-compose logs --tail=50 telemetry-api
```

### Verify Everything is Working
```bash
./verify_grafana.sh
```
**Checks:**
- ✅ Telemetry API responding
- ✅ Prometheus scraping
- ✅ Grafana datasource configured
- ✅ Dashboard exists
- ✅ Data flowing

---

## 🧪 Test & Query

### Test Telemetry API
```bash
# Health check
curl http://localhost:8000/health

# Get current status (JSON)
curl -s http://localhost:8000/status | python3 -m json.tool

# Get metrics (Prometheus format)
curl http://localhost:8000/metrics

# View API docs
open http://localhost:8000/docs
```

### Query Prometheus
```bash
# Query current CPU
curl -s 'http://localhost:9090/api/v1/query?query=device_cpu_usage' | python3 -m json.tool

# Query latency
curl -s 'http://localhost:9090/api/v1/query?query=device_latency_ms' | python3 -m json.tool

# Query packet loss
curl -s 'http://localhost:9090/api/v1/query?query=device_packet_loss' | python3 -m json.tool
```

### Kafka Operations
```bash
# List topics
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092

# Check topic details
docker exec -it kafka kafka-topics --describe --topic telemetry_stream --bootstrap-server localhost:9092

# Consume messages (live)
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic telemetry_stream \
  --from-beginning
```

---

## 🆘 Troubleshooting

### Services Not Starting
```bash
# Check what's running
docker ps

# Stop everything
docker-compose down

# Start fresh
docker-compose up -d

# View logs for errors
docker-compose logs
```

### Port Already in Use
```bash
# Find what's using port 8000
lsof -i :8000

# Kill the process or change ports in docker-compose.yml
```

### Grafana Shows No Data
```bash
# Verify data flow
./verify_grafana.sh

# Check time range (set to "Last 5 minutes")
# Enable auto-refresh (5s)
# Click refresh button

# Restart Grafana
docker-compose restart grafana
```

### Container Keeps Restarting
```bash
# Check logs
docker logs <container-name>

# Example
docker logs telemetry-api
docker logs kafka-consumer

# Rebuild container
docker-compose up -d --build <service-name>
```

### Reset Everything
```bash
# Stop and remove all data
docker-compose down -v

# Remove Docker cache
docker system prune -a

# Start fresh
docker-compose up -d --build
```

## Alert System

### Two Independent Alert Mechanisms:

**1. Kafka Consumer (Real-time)**
- Immediate detection on stream
- Logs to `alert.log`

**2. Prometheus Alerting (Time-series)**
- Fires when condition persists for 1 minute
- Sends to Alertmanager → FastAPI `/alert` endpoint

### Alert Thresholds
- CPU > 80%
- Latency > 300ms
- Packet loss > 5%

## Metrics Update Frequency
- Generated: Every 5 seconds
- Scraped by Prometheus: Every 5 seconds
- Alert evaluation: Every 5 seconds
- Grafana refresh: Every 5 seconds

---

## 📋 Quick Reference

### Essential Commands

| Action | Command |
|--------|---------|
| **Start** | `docker-compose up -d` |
| **Stop (keep data)** | `docker-compose down` |
| **Stop (remove data)** | `docker-compose down -v` |
| **Restart** | `docker-compose restart` |
| **View status** | `docker-compose ps` |
| **View logs** | `docker-compose logs -f` |
| **Open Grafana** | `open http://localhost:3000/d/telemetry-dashboard` |
| **Watch alerts** | `tail -f logs/alert.log` |
| **Live data stream** | `./live_data.sh` |
| **Verify system** | `./verify_grafana.sh` |

### Service Ports

| Service | Port | URL |
|---------|------|-----|
| Telemetry API | 8000 | http://localhost:8000 |
| Prometheus | 9090 | http://localhost:9090 |
| Alertmanager | 9093 | http://localhost:9093 |
| Grafana | 3000 | http://localhost:3000 |
| Kafka | 9092 | localhost:9092 |
| Zookeeper | 2181 | localhost:2181 |

### Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| Grafana | admin | admin |

### Alert Thresholds

| Metric | Threshold | Duration |
|--------|-----------|----------|
| CPU Usage | > 80% | 1 minute (Prometheus) / Immediate (Kafka) |
| Latency | > 300ms | 1 minute (Prometheus) / Immediate (Kafka) |
| Packet Loss | > 5% | 1 minute (Prometheus) / Immediate (Kafka) |

---

## 📚 More Documentation

- **README.md** - Comprehensive documentation with architecture diagrams
- **DEMO_GUIDE.md** - Demo script usage guide
- **SESSION_SUMMARY.md** - Complete session notes and troubleshooting
- **LICENSE** - MIT License

---

## 🎯 Typical Workflow

### Daily Use
```bash
# Morning - Start work
docker-compose up -d

# Open Grafana
open http://localhost:3000/d/telemetry-dashboard

# Monitor alerts (optional)
tail -f logs/alert.log

# Evening - Stop work
docker-compose down
```

### Development
```bash
# Start system
docker-compose up -d

# Make code changes...

# Restart service to apply changes
docker-compose restart telemetry-api

# View logs
docker-compose logs -f telemetry-api

# Done
docker-compose down
```

### Testing
```bash
# Start with demo
./demo.sh

# Test in browser
open http://localhost:3000/d/telemetry-dashboard

# Test API
curl http://localhost:8000/status | python3 -m json.tool

# Watch Kafka stream
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic telemetry_stream \
  --from-beginning

# Stop
docker-compose down
```

---

**🎉 You're all set! Start with `docker-compose up -d` and open Grafana!**
