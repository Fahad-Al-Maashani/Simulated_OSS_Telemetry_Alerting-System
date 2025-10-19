"""
FastAPI Telemetry API - Network Device Simulator
Simulates 3 network devices generating metrics every 2 seconds
"""

import asyncio
import json
import os
import random
import time
from datetime import datetime
from typing import Dict, List, Optional, Any
from fastapi import FastAPI, Request
from fastapi.responses import PlainTextResponse
from contextlib import asynccontextmanager
from aiokafka import AIOKafkaProducer
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Device names
DEVICES = ["Router-1", "Router-2", "Router-3"]

# Kafka configuration
KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
KAFKA_TOPIC = "telemetry_stream"

# Global storage for latest metrics
latest_metrics: Dict[str, Dict[str, float]] = {}
metrics_lock = asyncio.Lock()
kafka_producer: Optional[AIOKafkaProducer] = None


def generate_device_metrics(device_name: str) -> Dict[str, float]:
    """Generate random metrics for a device"""
    return {
        "cpu_usage": round(random.uniform(10.0, 95.0), 2),
        "latency_ms": round(random.uniform(1.0, 100.0), 2),
        "packet_loss": round(random.uniform(0.0, 5.0), 2),
        "timestamp": time.time()
    }


async def send_to_kafka(metrics_batch: Dict[str, Dict[str, float]]):
    """Send metrics batch to Kafka"""
    global kafka_producer
    if kafka_producer is None:
        logger.warning("Kafka producer not initialized")
        return
    
    try:
        # Prepare message
        message = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "devices": []
        }
        
        for device, metrics in metrics_batch.items():
            device_data = {
                "name": device,
                "cpu_usage": metrics["cpu_usage"],
                "latency_ms": metrics["latency_ms"],
                "packet_loss": metrics["packet_loss"],
                "metric_timestamp": metrics["timestamp"]
            }
            message["devices"].append(device_data)
        
        # Send to Kafka
        await kafka_producer.send_and_wait(
            KAFKA_TOPIC,
            json.dumps(message).encode('utf-8')
        )
        logger.info(f"Sent metrics batch to Kafka topic '{KAFKA_TOPIC}'")
    except Exception as e:
        logger.error(f"Failed to send metrics to Kafka: {e}")


async def metrics_generator():
    """Background task to generate metrics every 5 seconds"""
    while True:
        metrics_batch = {}
        async with metrics_lock:
            for device in DEVICES:
                latest_metrics[device] = generate_device_metrics(device)
                metrics_batch[device] = latest_metrics[device].copy()
        
        # Send to Kafka
        await send_to_kafka(metrics_batch)
        
        await asyncio.sleep(2)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle"""
    global kafka_producer
    
    # Initialize Kafka producer
    logger.info(f"Connecting to Kafka at {KAFKA_BOOTSTRAP_SERVERS}")
    kafka_producer = AIOKafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_serializer=lambda v: v if isinstance(v, bytes) else v.encode('utf-8')
    )
    
    try:
        await kafka_producer.start()
        logger.info("Kafka producer started successfully")
    except Exception as e:
        logger.error(f"Failed to start Kafka producer: {e}")
        kafka_producer = None
    
    # Initialize metrics
    for device in DEVICES:
        latest_metrics[device] = generate_device_metrics(device)
    
    # Start background task
    task = asyncio.create_task(metrics_generator())
    
    yield
    
    # Cleanup
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        pass
    
    # Stop Kafka producer
    if kafka_producer is not None:
        await kafka_producer.stop()
        logger.info("Kafka producer stopped")


app = FastAPI(
    title="Telemetry API",
    description="Network Device Telemetry Simulator",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/", tags=["Root"])
async def root():
    """Root endpoint with API information"""
    return {
        "service": "Telemetry API",
        "version": "1.0.0",
        "devices": DEVICES,
        "kafka_enabled": kafka_producer is not None,
        "kafka_topic": KAFKA_TOPIC,
        "endpoints": {
            "/metrics": "Prometheus-formatted metrics",
            "/status": "JSON snapshot of latest readings"
        }
    }


@app.get("/metrics", response_class=PlainTextResponse, tags=["Metrics"])
async def get_metrics():
    """
    Return Prometheus-formatted metrics for all devices
    """
    async with metrics_lock:
        prometheus_output = []
        
        # Add HELP and TYPE information
        prometheus_output.append("# HELP device_cpu_usage CPU usage percentage")
        prometheus_output.append("# TYPE device_cpu_usage gauge")
        
        prometheus_output.append("# HELP device_latency_ms Network latency in milliseconds")
        prometheus_output.append("# TYPE device_latency_ms gauge")
        
        prometheus_output.append("# HELP device_packet_loss Packet loss percentage")
        prometheus_output.append("# TYPE device_packet_loss gauge")
        
        # Add metrics for each device
        for device, metrics in latest_metrics.items():
            prometheus_output.append(
                f'device_cpu_usage{{device="{device}"}} {metrics["cpu_usage"]}'
            )
            prometheus_output.append(
                f'device_latency_ms{{device="{device}"}} {metrics["latency_ms"]}'
            )
            prometheus_output.append(
                f'device_packet_loss{{device="{device}"}} {metrics["packet_loss"]}'
            )
        
        return "\n".join(prometheus_output) + "\n"


@app.get("/status", tags=["Status"])
async def get_status():
    """
    Return JSON snapshot of latest readings for all devices
    """
    async with metrics_lock:
        status_data = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "devices": []
        }
        
        for device, metrics in latest_metrics.items():
            device_data = {
                "name": device,
                "cpu_usage_percent": metrics["cpu_usage"],
                "latency_ms": metrics["latency_ms"],
                "packet_loss_percent": metrics["packet_loss"],
                "last_updated": datetime.fromtimestamp(metrics["timestamp"]).isoformat() + "Z"
            }
            status_data["devices"].append(device_data)
        
        return status_data


@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "devices_count": len(DEVICES),
        "metrics_available": len(latest_metrics) > 0,
        "kafka_connected": kafka_producer is not None
    }


@app.post("/alert", tags=["Alerts"])
async def receive_alert(request: Request):
    """
    Receive alerts from Alertmanager and log them
    """
    try:
        alert_data = await request.json()
        
        # Log the full alert payload
        logger.info("="*60)
        logger.info("PROMETHEUS ALERT RECEIVED")
        logger.info("="*60)
        
        # Process each alert in the payload
        alerts = alert_data.get("alerts", [])
        
        for alert in alerts:
            status = alert.get("status", "unknown")
            labels = alert.get("labels", {})
            annotations = alert.get("annotations", {})
            
            alert_name = labels.get("alertname", "Unknown")
            device = annotations.get("device", labels.get("device", "Unknown"))
            severity = labels.get("severity", "unknown")
            
            # Format alert message
            if status == "firing":
                log_message = (
                    f"[PROMETHEUS ALERT - FIRING] "
                    f"Alert: {alert_name} | "
                    f"Device: {device} | "
                    f"Severity: {severity} | "
                    f"Summary: {annotations.get('summary', 'N/A')} | "
                    f"Description: {annotations.get('description', 'N/A')}"
                )
                logger.warning(log_message)
            elif status == "resolved":
                log_message = (
                    f"[PROMETHEUS ALERT - RESOLVED] "
                    f"Alert: {alert_name} | "
                    f"Device: {device} | "
                    f"Severity: {severity}"
                )
                logger.info(log_message)
            
        logger.info(f"Processed {len(alerts)} alert(s)")
        logger.info("="*60)
        
        return {
            "status": "success",
            "message": f"Received and logged {len(alerts)} alert(s)",
            "alerts_processed": len(alerts)
        }
        
    except Exception as e:
        logger.error(f"Error processing alert: {e}")
        return {
            "status": "error",
            "message": str(e)
        }
