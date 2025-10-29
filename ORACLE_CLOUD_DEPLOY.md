# Oracle Cloud Free Tier Deployment Guide

## Complete Kafka Telemetry Dashboard Deployment

This guide helps you deploy the full Kafka telemetry system on Oracle Cloud's **Always Free** tier.

---

## Prerequisites

- Oracle Cloud account (sign up at https://www.oracle.com/cloud/free/)
- GitHub repository with your code

---

## Step 1: Create Oracle Cloud VM

### 1.1 Sign in to Oracle Cloud Console
- Go to https://cloud.oracle.com/
- Click "Sign In"

### 1.2 Create Compute Instance
1. Navigate to: **Menu → Compute → Instances**
2. Click **"Create Instance"**

### 1.3 Configure Instance
- **Name**: `kafka-telemetry-dashboard`
- **Compartment**: Keep default (root)
- **Availability Domain**: Keep default
- **Image**: 
  - Click "Change Image"
  - Select **Ubuntu 22.04** (Minimal or Standard)
- **Shape**:
  - Click "Change Shape"
  - Select **VM.Standard.E2.1.Micro** (Always Free eligible)
  - 1 OCPU, 1 GB RAM
  - OR **VM.Standard.A1.Flex** (ARM, 4 OCPUs, 24GB RAM - better!)

### 1.4 Network Configuration
- **VCN**: Create new or use existing
- **Subnet**: Use public subnet
- **Public IP**: ✅ **Assign a public IPv4 address** (IMPORTANT!)

### 1.5 SSH Keys
- **Option A**: Generate new key pair (download both keys)
- **Option B**: Upload your existing public key

### 1.6 Boot Volume
- Keep default (50GB is enough)

### 1.7 Click **"Create"**
- Wait 1-2 minutes for instance to start
- Note down the **Public IP Address**

---

## Step 2: Configure Security (Firewall Rules)

### 2.1 Add Ingress Rules
1. Go to your instance details
2. Click **"Subnet"** link
3. Click your subnet name
4. Click **"Default Security List"**
5. Click **"Add Ingress Rules"**

### 2.2 Add These Ports:

**Rule 1: Grafana Dashboard**
- Source CIDR: `0.0.0.0/0`
- IP Protocol: TCP
- Destination Port: `3000`
- Description: Grafana Dashboard

**Rule 2: Prometheus**
- Source CIDR: `0.0.0.0/0`
- IP Protocol: TCP
- Destination Port: `9090`
- Description: Prometheus

**Rule 3: Telemetry API**
- Source CIDR: `0.0.0.0/0`
- IP Protocol: TCP
- Destination Port: `8000`
- Description: Telemetry API

**Rule 4: Alertmanager**
- Source CIDR: `0.0.0.0/0`
- IP Protocol: TCP
- Destination Port: `9093`
- Description: Alertmanager

---

## Step 3: Connect to Your VM

```bash
# Replace with your downloaded key and public IP
chmod 400 ~/Downloads/ssh-key-*.key
ssh -i ~/Downloads/ssh-key-*.key ubuntu@YOUR_PUBLIC_IP
```

Or if you used your own key:
```bash
ssh ubuntu@YOUR_PUBLIC_IP
```

---

## Step 4: Setup Docker on VM

Once connected to VM, run:

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install docker-compose -y

# Apply group changes (or logout and login)
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

---

## Step 5: Deploy Your Application

```bash
# Clone your repository
git clone https://github.com/Fahad-Al-Maashani/Simulated_OSS_Telemetry_Alerting-System.git
cd Simulated_OSS_Telemetry_Alerting-System

# Configure firewall on Ubuntu
sudo ufw allow 3000/tcp  # Grafana
sudo ufw allow 8000/tcp  # Telemetry API
sudo ufw allow 9090/tcp  # Prometheus
sudo ufw allow 9093/tcp  # Alertmanager
sudo ufw allow 22/tcp    # SSH
sudo ufw --force enable

# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## Step 6: Access Your Dashboard

### Grafana Dashboard:
- URL: `http://YOUR_PUBLIC_IP:3000`
- Username: `admin`
- Password: `admin`

### Prometheus:
- URL: `http://YOUR_PUBLIC_IP:9090`

### Telemetry API:
- URL: `http://YOUR_PUBLIC_IP:8000`
- Docs: `http://YOUR_PUBLIC_IP:8000/docs`

### Alertmanager:
- URL: `http://YOUR_PUBLIC_IP:9093`

---

## Step 7: Generate Demo Data

```bash
# SSH into VM, then run:
cd Simulated_OSS_Telemetry_Alerting-System

# Start demo script
./demo.sh

# Or manually send test data
curl -X POST http://localhost:8000/telemetry \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "2024-01-01T12:00:00",
    "service_name": "api-gateway",
    "metric_type": "response_time",
    "value": 150.5,
    "tags": {"env": "production", "region": "us-east"}
  }'
```

---

## Useful Commands

### Check Services Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f grafana
docker-compose logs -f kafka
```

### Restart Services
```bash
docker-compose restart
```

### Stop All Services
```bash
docker-compose down
```

### Update Code
```bash
git pull origin main
docker-compose down
docker-compose up -d --build
```

---

## Troubleshooting

### Services Won't Start
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check logs
docker-compose logs
```

### Can't Access Dashboard
1. Check Oracle Cloud Security List (firewall rules)
2. Check Ubuntu firewall: `sudo ufw status`
3. Check if services are running: `docker-compose ps`
4. Check service health: `docker-compose logs grafana`

### Out of Memory
```bash
# Check memory usage
free -h

# If using E2.1.Micro (1GB), might need to add swap:
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## Cost Monitoring

This setup uses Oracle's **Always Free** resources:
- ✅ 2 AMD-based VMs (1/8 OCPU, 1GB RAM each) OR
- ✅ 4 ARM-based VMs (up to 24GB RAM total)
- ✅ 2 Block Volumes (200GB total)
- ✅ 10TB outbound data transfer/month

**Your deployment is 100% FREE forever!**

---

## Share Your Dashboard

Once deployed, share these URLs:

```
Grafana Dashboard: http://YOUR_PUBLIC_IP:3000
Username: admin
Password: admin

Prometheus Metrics: http://YOUR_PUBLIC_IP:9090
Telemetry API Docs: http://YOUR_PUBLIC_IP:8000/docs
```

⚠️ **Security Note**: For production, change default passwords and add HTTPS!

---

## Next Steps

1. ✅ Deploy on Oracle Cloud
2. 🔐 Change Grafana password
3. 📊 Customize dashboards
4. 🔔 Configure real alert notifications
5. 🌐 Add custom domain (optional)
6. 🔒 Add SSL/HTTPS with Let's Encrypt (optional)
