# 🚀 OSS Telemetry & Alerting Dashboard

### Real-Time Operational Support System (OSS) Monitoring Simulation  
**Stack:** FastAPI • Kafka • Prometheus • Grafana • Alertmanager • Docker Compose  

---

## 📖 Overview

This project simulates a **telecom-grade Operational Support System (OSS)** that performs **real-time telemetry monitoring, alerting, and visualization**.  

It’s a **fully functional prototype** that demonstrates **integration, observability, and automation** — core skills required for OSS, DevOps, and Telecom Network Engineers.  

The system uses:
- 🐍 **FastAPI** to simulate network devices sending metrics.  
- 📨 **Kafka** as a reliable event streaming bus.  
- 📊 **Prometheus** to scrape metrics and trigger alerts.  
- 📈 **Grafana** for interactive dashboards.  
- ⚙️ **Docker Compose** to orchestrate all services.

---

## 🧭 System Architecture

Below is the architecture diagram showing the entire system flow and relationships between components.

```mermaid
graph TD
    subgraph Device_Simulation
        A[FastAPI - Device Simulator] -->|Generate Metrics| B[Kafka Producer]
    end

    subgraph Messaging_Pipeline
        B -->|Send JSON Metrics| C[Kafka Broker]
        C -->|Stream Data| D[Kafka Consumer]
        D -->|Analyze Metrics & Log Alerts| E[alert.log]
    end

    subgraph Monitoring_Stack
        A -->|Expose /metrics| F[Prometheus]
        F -->|Store & Evaluate Rules| G[Alertmanager]
        G -->|Send Alerts to Webhook| A
        F -->|Visualize| H[Grafana Dashboard]
    end

    style Device_Simulation fill:#F5F5DC,stroke:#333,stroke-width:1px
    style Messaging_Pipeline fill:#E0FFFF,stroke:#333,stroke-width:1px
    style Monitoring_Stack fill:#E6E6FA,stroke:#333,stroke-width:1px















oss-telemetry-dashboard/
│
├── docker-compose.yml
├── demo.sh
├── README.md
│
├── telemetry_api/
│   ├── main.py
│   ├── metrics_generator.py
│   ├── kafka_producer.py
│   ├── requirements.txt
│   ├── Dockerfile
│
├── kafka_consumer/
│   ├── consumer.py
│   ├── requirements.txt
│   ├── Dockerfile
│
├── prometheus/
│   ├── prometheus.yml
│   ├── alert_rules.yml
│   └── Dockerfile
│
├── alertmanager/
│   ├── alertmanager.yml
│   └── Dockerfile
│
├── grafana/
│   └── Dockerfile
│
└── assets/
    ├── architecture_diagram.mmd
    ├── dashboard_screenshot.png
    ├── alert_log_sample.png
