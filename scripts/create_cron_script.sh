#!/bin/bash

read -p "Enter the name of the new script (e.g., my_new_script.sh): " script_name

TEMPLATE_PATH=~/automation/configs/script_template.sh
SCRIPTS_DIR=~/automation/scripts
LOG_FILE=~/automation/logs/cron_job_creation.log
NEW_SCRIPT_PATH="$SCRIPTS_DIR/$script_name"
WRAPPER_SCRIPT=~/automation/scripts/cron_wrapper.sh

cp "$TEMPLATE_PATH" "$NEW_SCRIPT_PATH" && chmod +x "$NEW_SCRIPT_PATH"

read -p "Do you want to edit the script now? (y/n): " edit_choice
[[ "$edit_choice" =~ ^[Yy]$ ]] && nano "$NEW_SCRIPT_PATH"

read -p "Do you want to set up a cron job for this script? (y/n): " cron_choice
if [[ "$cron_choice" =~ ^[Yy]$ ]]; then
    echo "1. Every minute"
    echo "2. Every hour"
    echo "3. Daily"
    echo "4. Weekly"
    echo "5. Monthly"
    echo "6. Custom"
    read -p "Choose an option (1-6): " freq

    case $freq in
        1) cron_schedule="* * * * *" ;;
        2) cron_schedule="0 * * * *" ;;
        3) cron_schedule="0 0 * * *" ;;
        4) cron_schedule="0 0 * * 0" ;;
        5) cron_schedule="0 0 1 * *" ;;
        6) read -p "Enter custom schedule: " cron_schedule ;;
    esac

    cron_job="$cron_schedule $WRAPPER_SCRIPT $NEW_SCRIPT_PATH"
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    echo "[$(date)] Added cron job: $cron_job" >> "$LOG_FILE"
fi

