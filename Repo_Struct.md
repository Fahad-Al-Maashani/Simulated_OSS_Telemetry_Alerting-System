```
oss-telemetry-dashboard/
|
|-- docker-compose.yml
|-- demo.sh
|-- README.md
|
|-- telemetry_api/
|   |-- main.py
|   |-- metrics_generator.py
|   |-- kafka_producer.py
|   |-- requirements.txt
|   |-- Dockerfile
|
|-- kafka_consumer/
|   |-- consumer.py
|   |-- requirements.txt
|   |-- Dockerfile
|
|-- prometheus/
|   |-- prometheus.yml
|   |-- alert_rules.yml
|   |-- Dockerfile
|
|-- alertmanager/
|   |-- alertmanager.yml
|   |-- Dockerfile
|
|-- grafana/
|   |-- Dockerfile
|
|-- assets/
|   |-- architecture_diagram.mmd
|   |-- dashboard_screenshot.png
|   |-- alert_log_sample.png
