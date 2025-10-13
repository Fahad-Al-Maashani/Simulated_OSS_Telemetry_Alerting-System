## 🧭 System Architecture

This project simulates a telecom OSS telemetry and alerting pipeline using FastAPI, Kafka, Prometheus, and Grafana.

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
