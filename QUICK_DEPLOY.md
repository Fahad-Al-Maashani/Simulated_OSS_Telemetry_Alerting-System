# 🚀 Quick Deploy Guide - Oracle Cloud Free Tier

## Deploy Your Full Kafka Dashboard in 15 Minutes (100% Free Forever!)

---

## Step 1: Create Oracle Cloud Account (5 min)

1. Go to: https://www.oracle.com/cloud/free/
2. Click **"Start for free"**
3. Fill in details (requires credit card for verification but **won't be charged**)
4. Verify email
5. Sign in to console: https://cloud.oracle.com/

---

## Step 2: Create VM Instance (3 min)

1. **Menu** → **Compute** → **Instances** → **Create Instance**

2. **Quick Config:**
   - Name: `kafka-dashboard`
   - Image: **Ubuntu 22.04**
   - Shape: **VM.Standard.E2.1.Micro** (Always Free) or **VM.Standard.A1.Flex** (4 OCPU, 24GB - Better!)
   - ✅ **Assign public IP address**
   - SSH: Download or upload your key
   
3. Click **Create**

4. **Save your Public IP address!** (shown after creation)

---

## Step 3: Open Firewall Ports (2 min)

1. Click your instance → **Subnet** → **Security List**
2. Click **Add Ingress Rules** (do this 4 times):

**Port 3000** (Grafana):
```
Source: 0.0.0.0/0
Protocol: TCP
Port: 3000
```

**Port 8000** (API):
```
Source: 0.0.0.0/0
Protocol: TCP
Port: 8000
```

**Port 9090** (Prometheus):
```
Source: 0.0.0.0/0
Protocol: TCP
Port: 9090
```

**Port 9093** (Alertmanager):
```
Source: 0.0.0.0/0
Protocol: TCP
Port: 9093
```

---

## Step 4: Connect & Setup (5 min)

### Connect to VM:
```bash
# Replace with your IP and key file
ssh -i ~/Downloads/your-key.key ubuntu@YOUR_PUBLIC_IP
```

### Run automated setup:
```bash
# Download and run setup script
curl -sSL https://raw.githubusercontent.com/Fahad-Al-Maashani/Simulated_OSS_Telemetry_Alerting-System/main/oracle-setup.sh | bash

# Logout and login again
exit
ssh -i ~/Downloads/your-key.key ubuntu@YOUR_PUBLIC_IP

# Start services
cd Simulated_OSS_Telemetry_Alerting-System
docker-compose up -d
```

### Check status:
```bash
docker-compose ps
```

Wait 1-2 minutes for all services to start.

---

## Step 5: Access Your Dashboard! 🎉

Replace `YOUR_IP` with your public IP:

### 📊 Grafana Dashboard
**URL:** `http://YOUR_IP:3000`
- Username: `admin`
- Password: `admin`

### 🔍 Prometheus
**URL:** `http://YOUR_IP:9090`

### 📡 Telemetry API
**URL:** `http://YOUR_IP:8000/docs`

### 🔔 Alertmanager
**URL:** `http://YOUR_IP:9093`

---

## Step 6: Generate Demo Data

```bash
# SSH into VM
ssh ubuntu@YOUR_IP

# Run demo script
cd Simulated_OSS_Telemetry_Alerting-System
./demo.sh
```

Or send manual test data:
```bash
curl -X POST http://localhost:8000/telemetry \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "2024-01-01T12:00:00",
    "service_name": "api-gateway",
    "metric_type": "response_time",
    "value": 250.5
  }'
```

---

## 🎯 What You Get

✅ **Full Kafka Streaming Pipeline**
- Real-time data ingestion
- Kafka + Zookeeper cluster
- Consumer processing

✅ **Complete Monitoring Stack**
- Prometheus metrics collection
- Grafana dashboards
- Alertmanager notifications

✅ **Production-Ready API**
- FastAPI telemetry endpoint
- OpenAPI documentation
- Health checks

✅ **100% Free Forever**
- Oracle Always Free tier
- No expiration
- No hidden costs

---

## 📤 Share Your Dashboard

Give people these URLs:

```
🌐 Dashboard: http://YOUR_IP:3000
👤 Username: admin
🔑 Password: admin

📊 Metrics: http://YOUR_IP:9090
📚 API Docs: http://YOUR_IP:8000/docs
```

---

## 🛠️ Common Commands

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop all
docker-compose down

# Update code
git pull
docker-compose up -d --build

# Check service health
docker-compose ps
```

---

## 🔒 Security Tips

For production use:

1. **Change Grafana password:**
   - Login → Profile → Change Password

2. **Add authentication to Prometheus:**
   - Edit prometheus.yml

3. **Setup HTTPS:**
   - Use Nginx reverse proxy
   - Get free SSL with Let's Encrypt

4. **Restrict IP access:**
   - Update Oracle Security List
   - Allow only your IP

---

## ❓ Troubleshooting

### Can't access dashboard?
```bash
# Check services are running
docker-compose ps

# Check firewall
sudo ufw status

# View logs
docker-compose logs grafana
```

### Out of memory?
```bash
# Check memory
free -h

# Restart with less memory
docker-compose down
docker-compose up -d
```

### Services keep restarting?
```bash
# Check specific service logs
docker-compose logs kafka
docker-compose logs telemetry-api

# Restart Docker
sudo systemctl restart docker
```

---

## 🎓 Next Steps

1. ✅ Deploy on Oracle Cloud
2. 📊 Explore Grafana dashboards  
3. 📡 Send custom telemetry data
4. 🔔 Configure alert rules
5. 🎨 Customize dashboards
6. 🌐 Add custom domain (optional)
7. 🔐 Setup HTTPS (optional)

---

## 💡 Tips

- Oracle Always Free never expires
- VM stays running 24/7
- Perfect for portfolio demos
- Share with potential employers
- Great for learning DevOps

---

**Need help?** Check `ORACLE_CLOUD_DEPLOY.md` for detailed instructions!

**Questions?** Open an issue on GitHub!
