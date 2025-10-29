"""
Kafka Consumer Service - Telemetry Alert Monitor
Consumes telemetry_stream topic and logs alerts for anomalies
"""

import asyncio
import json
import os
import logging
from datetime import datetime
from aiokafka import AIOKafkaConsumer

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/alert.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)
alert_logger = logging.getLogger('alerts')

# Kafka configuration
KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
KAFKA_TOPIC = "telemetry_stream"
KAFKA_GROUP_ID = "telemetry-alert-consumer"

# Alert thresholds
CPU_THRESHOLD = 80.0
LATENCY_THRESHOLD = 300.0
PACKET_LOSS_THRESHOLD = 5.0


def check_alerts(device_data: dict) -> list:
    """
    Check device metrics against thresholds and return list of alerts
    """
    alerts = []
    device_name = device_data.get("name", "Unknown")
    cpu_usage = device_data.get("cpu_usage", 0)
    latency_ms = device_data.get("latency_ms", 0)
    packet_loss = device_data.get("packet_loss", 0)
    
    if cpu_usage > CPU_THRESHOLD:
        alerts.append({
            "type": "CPU_HIGH",
            "device": device_name,
            "value": cpu_usage,
            "threshold": CPU_THRESHOLD,
            "message": f"CPU usage {cpu_usage}% exceeds threshold {CPU_THRESHOLD}%"
        })
    
    if latency_ms > LATENCY_THRESHOLD:
        alerts.append({
            "type": "LATENCY_HIGH",
            "device": device_name,
            "value": latency_ms,
            "threshold": LATENCY_THRESHOLD,
            "message": f"Latency {latency_ms}ms exceeds threshold {LATENCY_THRESHOLD}ms"
        })
    
    if packet_loss > PACKET_LOSS_THRESHOLD:
        alerts.append({
            "type": "PACKET_LOSS_HIGH",
            "device": device_name,
            "value": packet_loss,
            "threshold": PACKET_LOSS_THRESHOLD,
            "message": f"Packet loss {packet_loss}% exceeds threshold {PACKET_LOSS_THRESHOLD}%"
        })
    
    return alerts


def log_alert(alert: dict, batch_timestamp: str):
    """Log alert to alert.log"""
    alert_message = (
        f"[ALERT] {alert['type']} | "
        f"Device: {alert['device']} | "
        f"Value: {alert['value']} | "
        f"Threshold: {alert['threshold']} | "
        f"Batch Time: {batch_timestamp} | "
        f"Message: {alert['message']}"
    )
    alert_logger.warning(alert_message)


async def consume_telemetry():
    """
    Main consumer loop - consume messages from Kafka and check for alerts
    """
    logger.info(f"Starting Kafka consumer for topic '{KAFKA_TOPIC}'")
    logger.info(f"Connecting to Kafka at {KAFKA_BOOTSTRAP_SERVERS}")
    logger.info(f"Alert thresholds: CPU > {CPU_THRESHOLD}%, Latency > {LATENCY_THRESHOLD}ms, Packet Loss > {PACKET_LOSS_THRESHOLD}%")
    
    consumer = AIOKafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        group_id=KAFKA_GROUP_ID,
        auto_offset_reset='latest',  # Start from latest messages
        enable_auto_commit=True,
        value_deserializer=lambda m: json.loads(m.decode('utf-8'))
    )
    
    try:
        await consumer.start()
        logger.info("Kafka consumer started successfully")
        logger.info("Monitoring for anomalies...")
        
        async for message in consumer:
            try:
                data = message.value
                batch_timestamp = data.get("timestamp", "Unknown")
                devices = data.get("devices", [])
                
                logger.info(f"Received metrics batch with {len(devices)} devices at {batch_timestamp}")
                
                # Check each device for alerts
                total_alerts = 0
                for device_data in devices:
                    alerts = check_alerts(device_data)
                    for alert in alerts:
                        log_alert(alert, batch_timestamp)
                        total_alerts += 1
                
                if total_alerts > 0:
                    logger.info(f"Generated {total_alerts} alert(s) for this batch")
                else:
                    logger.debug("No alerts for this batch")
                    
            except Exception as e:
                logger.error(f"Error processing message: {e}")
                
    except Exception as e:
        logger.error(f"Consumer error: {e}")
    finally:
        await consumer.stop()
        logger.info("Kafka consumer stopped")


async def main():
    """Main entry point"""
    logger.info("=" * 60)
    logger.info("Telemetry Alert Monitor Starting")
    logger.info("=" * 60)
    
    try:
        await consume_telemetry()
    except KeyboardInterrupt:
        logger.info("Received shutdown signal")
    except Exception as e:
        logger.error(f"Fatal error: {e}")
    finally:
        logger.info("Telemetry Alert Monitor Stopped")


if __name__ == "__main__":
    asyncio.run(main())
