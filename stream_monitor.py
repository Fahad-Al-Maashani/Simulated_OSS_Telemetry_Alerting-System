#!/usr/bin/env python3
"""
Real-time Telemetry Data Stream Monitor
Visualizes live data from the Telemetry API with color-coded output
"""

import requests
import time
import os
from datetime import datetime

# ANSI color codes
RESET = '\033[0m'
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
MAGENTA = '\033[95m'
CYAN = '\033[96m'
BOLD = '\033[1m'

# Thresholds
CPU_THRESHOLD = 80.0
LATENCY_THRESHOLD = 300.0
PACKET_LOSS_THRESHOLD = 5.0

def clear_screen():
    """Clear the terminal screen"""
    os.system('clear' if os.name != 'nt' else 'cls')

def get_color_for_cpu(value):
    """Return color based on CPU value"""
    if value > CPU_THRESHOLD:
        return RED
    elif value > 60:
        return YELLOW
    else:
        return GREEN

def get_color_for_latency(value):
    """Return color based on latency value"""
    if value > LATENCY_THRESHOLD:
        return RED
    elif value > 150:
        return YELLOW
    else:
        return GREEN

def get_color_for_packet_loss(value):
    """Return color based on packet loss value"""
    if value > PACKET_LOSS_THRESHOLD:
        return RED
    elif value > 2:
        return YELLOW
    else:
        return GREEN

def create_bar(value, max_value=100, width=30):
    """Create a visual bar chart"""
    filled = int((value / max_value) * width)
    bar = '█' * filled + '░' * (width - filled)
    return bar

def fetch_data():
    """Fetch data from the Telemetry API"""
    try:
        response = requests.get('http://localhost:8000/status', timeout=2)
        if response.status_code == 200:
            return response.json()
        else:
            return None
    except Exception as e:
        return None

def display_data(data):
    """Display data with colors and bars"""
    clear_screen()
    
    # Header
    print(f"{BOLD}{CYAN}{'='*80}{RESET}")
    print(f"{BOLD}{CYAN}           🌐 NETWORK TELEMETRY REAL-TIME MONITOR 🌐{RESET}")
    print(f"{BOLD}{CYAN}{'='*80}{RESET}\n")
    
    if not data:
        print(f"{RED}❌ Unable to fetch data from API. Is the service running?{RESET}")
        print(f"{YELLOW}Run: docker-compose ps{RESET}")
        return
    
    timestamp = data.get('timestamp', 'N/A')
    print(f"{BOLD}⏰ Last Update:{RESET} {BLUE}{timestamp}{RESET}")
    print(f"{BOLD}🔄 Refresh Rate:{RESET} {GREEN}Every 2 seconds{RESET}\n")
    
    devices = data.get('devices', [])
    
    for device in devices:
        name = device.get('name', 'Unknown')
        cpu = device.get('cpu_usage_percent', 0)
        latency = device.get('latency_ms', 0)
        packet_loss = device.get('packet_loss_percent', 0)
        
        # Device header
        print(f"{BOLD}{MAGENTA}{'─'*80}{RESET}")
        print(f"{BOLD}{MAGENTA}📡 {name}{RESET}")
        print(f"{BOLD}{MAGENTA}{'─'*80}{RESET}")
        
        # CPU Usage
        cpu_color = get_color_for_cpu(cpu)
        cpu_bar = create_bar(cpu, 100, 40)
        cpu_status = "🔥 ALERT!" if cpu > CPU_THRESHOLD else "✅ OK"
        print(f"{BOLD}  CPU Usage:{RESET}")
        print(f"    {cpu_color}{cpu_bar}{RESET} {cpu_color}{BOLD}{cpu:.2f}%{RESET} {cpu_status}")
        print(f"    Threshold: {RED}{CPU_THRESHOLD}%{RESET}\n")
        
        # Latency
        latency_color = get_color_for_latency(latency)
        latency_bar = create_bar(latency, 500, 40)
        latency_status = "🔥 ALERT!" if latency > LATENCY_THRESHOLD else "✅ OK"
        print(f"{BOLD}  Network Latency:{RESET}")
        print(f"    {latency_color}{latency_bar}{RESET} {latency_color}{BOLD}{latency:.2f}ms{RESET} {latency_status}")
        print(f"    Threshold: {RED}{LATENCY_THRESHOLD}ms{RESET}\n")
        
        # Packet Loss
        pl_color = get_color_for_packet_loss(packet_loss)
        pl_bar = create_bar(packet_loss, 10, 40)
        pl_status = "🔥 ALERT!" if packet_loss > PACKET_LOSS_THRESHOLD else "✅ OK"
        print(f"{BOLD}  Packet Loss:{RESET}")
        print(f"    {pl_color}{pl_bar}{RESET} {pl_color}{BOLD}{packet_loss:.2f}%{RESET} {pl_status}")
        print(f"    Threshold: {RED}{PACKET_LOSS_THRESHOLD}%{RESET}\n")
    
    # Footer
    print(f"{BOLD}{CYAN}{'='*80}{RESET}")
    print(f"{CYAN}💡 Tip: Open Grafana for advanced visualization → http://localhost:3000{RESET}")
    print(f"{CYAN}📊 Press Ctrl+C to stop monitoring{RESET}")
    print(f"{BOLD}{CYAN}{'='*80}{RESET}")

def main():
    """Main monitoring loop"""
    print(f"{BOLD}{GREEN}Starting Real-Time Telemetry Monitor...{RESET}")
    time.sleep(1)
    
    try:
        while True:
            data = fetch_data()
            display_data(data)
            time.sleep(2)  # Update every 2 seconds
    except KeyboardInterrupt:
        clear_screen()
        print(f"\n{BOLD}{GREEN}✅ Monitoring stopped. Thank you!{RESET}\n")
    except Exception as e:
        print(f"\n{RED}❌ Error: {e}{RESET}\n")

if __name__ == "__main__":
    main()
