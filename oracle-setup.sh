#!/bin/bash

# Oracle Cloud VM Setup Script for Kafka Telemetry Dashboard
# Run this script after connecting to your Oracle Cloud VM

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   Kafka Telemetry Dashboard - Oracle Cloud Setup         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root"
    exit 1
fi

# Step 1: Update System
print_step "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y
print_success "System updated"

# Step 2: Install Docker
print_step "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed"
else
    print_success "Docker already installed"
fi

# Step 3: Install Docker Compose
print_step "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo apt-get install docker-compose -y
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Step 4: Install Git
print_step "Installing Git..."
if ! command -v git &> /dev/null; then
    sudo apt-get install git -y
    print_success "Git installed"
else
    print_success "Git already installed"
fi

# Step 5: Configure Firewall
print_step "Configuring Ubuntu firewall..."
sudo ufw --force enable
sudo ufw allow 22/tcp comment "SSH"
sudo ufw allow 3000/tcp comment "Grafana"
sudo ufw allow 8000/tcp comment "Telemetry API"
sudo ufw allow 9090/tcp comment "Prometheus"
sudo ufw allow 9093/tcp comment "Alertmanager"
sudo ufw reload
print_success "Firewall configured"

# Step 6: Create swap space (helpful for 1GB RAM instances)
print_step "Creating swap space..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    print_success "Swap space created (2GB)"
else
    print_success "Swap space already exists"
fi

# Step 7: Clone Repository
print_step "Cloning repository..."
REPO_URL="https://github.com/Fahad-Al-Maashani/Simulated_OSS_Telemetry_Alerting-System.git"
REPO_DIR="Simulated_OSS_Telemetry_Alerting-System"

if [ -d "$REPO_DIR" ]; then
    print_warning "Repository directory already exists. Updating..."
    cd $REPO_DIR
    git pull origin main
    cd ..
else
    git clone $REPO_URL
fi
print_success "Repository ready"

# Step 8: Apply docker group (without logout)
print_step "Applying docker group permissions..."
newgrp docker << END
cd $REPO_DIR
print_success "Docker group applied"
END

# Step 9: Display instructions
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                  Setup Complete! 🎉                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "1. Logout and login again (or run: newgrp docker)"
echo "   ${YELLOW}exit${NC}"
echo "   ${YELLOW}ssh ubuntu@<your-vm-ip>${NC}"
echo ""
echo "2. Start the services:"
echo "   ${YELLOW}cd $REPO_DIR${NC}"
echo "   ${YELLOW}docker-compose up -d${NC}"
echo ""
echo "3. Check status:"
echo "   ${YELLOW}docker-compose ps${NC}"
echo ""
echo "4. Generate demo data:"
echo "   ${YELLOW}./demo.sh${NC}"
echo ""
echo -e "${GREEN}Access Your Dashboard:${NC}"
echo ""
PUBLIC_IP=$(curl -s ifconfig.me)
echo "   Grafana:    ${BLUE}http://$PUBLIC_IP:3000${NC}"
echo "               Username: admin | Password: admin"
echo ""
echo "   Prometheus: ${BLUE}http://$PUBLIC_IP:9090${NC}"
echo "   API Docs:   ${BLUE}http://$PUBLIC_IP:8000/docs${NC}"
echo "   Alerts:     ${BLUE}http://$PUBLIC_IP:9093${NC}"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
print_warning "IMPORTANT: Change default Grafana password after first login!"
echo ""
