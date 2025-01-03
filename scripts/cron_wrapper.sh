#!/bin/bash
# Cron job wrapper for logging and error handling

if [ -z "$1" ]; then
    echo "Usage: $0 <script_path>"
    exit 1
fi

SCRIPT=$1
LOG_FILE=~/automation/logs/cron_$(basename "$SCRIPT" .sh).log

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting $SCRIPT" >> "$LOG_FILE"
bash "$SCRIPT" >> "$LOG_FILE" 2>&1
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Completed $SCRIPT" >> "$LOG_FILE"

