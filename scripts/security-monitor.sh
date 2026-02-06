#!/bin/bash
# Monitoring sécurité OpenClaw

LOG_FILE="/home/cherubin/.openclaw/logs/security.log"
ALERT_FILE="/home/cherubin/.openclaw/logs/alerts.log"

while true; do
    if tail -n 10 $LOG_FILE | grep -q "Unauthorized\|Failed\|Error"; then
        echo "[$(date)] ALERT: Suspicious activity detected" >> $ALERT_FILE
    fi
    sleep 300
done
