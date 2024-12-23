# CronSetup

Here’s a robust process for creating and managing scripts and cron jobs for an Ubuntu 24 desktop machine that will function as an automation screen. This process integrates best practices for **script management**, **cron job creation**, **logging**, and **maintenance**.

---

### **1. Directory Structure for Scripts and Logs**
Create a structured directory system for organization and easy management:
```bash
mkdir -p ~/automation/{scripts,logs,configs,backups}
```

- **`~/automation/scripts/`**: Store all automation scripts.
- **`~/automation/logs/`**: Store all logs.
- **`~/automation/configs/`**: Store configuration files.
- **`~/automation/backups/`**: Store backups of critical scripts and cron configurations.

---

### **2. Standard Script Template**
Use a standard template for creating scripts to ensure consistency.

#### Create a Template File (`~/automation/configs/script_template.sh`):
```bash
#!/bin/bash

# Script Template
# Author: Your Name
# Created: $(date +"%Y-%m-%d")
# Purpose: Describe the purpose of this script.

# Load environment variables
source ~/automation/configs/env.sh

# Define script name for logging
SCRIPT_NAME=$(basename "$0")

# Main script logic here


# End script

```

#### Usage:
1. Copy the template:
   ```bash
   cp ~/automation/configs/script_template.sh ~/automation/scripts/my_new_script.sh
   ```
2. Make it executable:
   ```bash
   chmod +x ~/automation/scripts/my_new_script.sh
   ```
3. Edit the script with your logic:
   ```bash
   nano ~/automation/scripts/my_new_script.sh
   ```

---

### **3. Environment Variables File**
Use a centralized file for environment variables.

#### Create an Environment Variables File (`~/automation/configs/env.sh`):
```bash
#!/bin/bash
# Environment variables for automation scripts

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export BACKUP_DIR="~/automation/backups"
export LOG_DIR="~/automation/logs"
export DB_USER="your_database_user"
export DB_PASS="your_database_password"
```

#### Load the Variables:
Ensure every script sources this file: (This is already done if using automated script or copying the templated script)
```bash
source ~/automation/configs/env.sh
```

---

### **4. Cron Job Management**
Create and manage cron jobs systematically.

#### Example Workflow for Cron Jobs:
1. **Create a Wrapper Script for Cron Jobs:**
   Save the following as `~/automation/scripts/cron_wrapper.sh`:
   ```bash
   #!/bin/bash
   # Cron job wrapper to ensure consistent logging and error handling.

   if [ -z "$1" ]; then
       echo "Usage: $0 <script_path>"
       exit 1
   fi

   SCRIPT=$1
   LOG_FILE=~/automation/logs/cron_$(basename "$SCRIPT" .sh).log

   echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting $SCRIPT" >> "$LOG_FILE"
   bash "$SCRIPT" >> "$LOG_FILE" 2>&1
   echo "[$(date +"%Y-%m-%d %H:%M:%S")] Completed $SCRIPT" >> "$LOG_FILE"
   ```

2. **Add a Cron Job Using the Wrapper:**
   Edit your crontab:
   ```bash
   crontab -e
   ```
   Add a job:
   ```bash
   * * * * * ~/automation/scripts/cron_wrapper.sh ~/automation/scripts/my_new_script.sh
   ```

#### Benefits:
- Centralized logging for all cron jobs.
- Consistent error handling.

---

### **5. Logging Best Practices**
- **Centralize Logs:** Store all logs in `~/automation/logs/`.
- **Use Descriptive Log Names:** Include script names and timestamps.
- **Rotate Logs Automatically:**
  Configure `logrotate` to manage logs.

#### Configure Log Rotation (`/etc/logrotate.d/automation`):
```bash
~/automation/logs/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
```

---

### **6. Automating New Script and Cronjob Creation**
- **Create script to combine steps above
```bash
#!/bin/bash

# Prompt for the new script name
read -p "Enter the name of the new script (e.g., my_new_script.sh): " script_name

# Define paths
TEMPLATE_PATH=~/automation/configs/script_template.sh
SCRIPTS_DIR=~/automation/scripts
LOG_FILE=~/automation/logs/cron_job_creation.log
NEW_SCRIPT_PATH="$SCRIPTS_DIR/$script_name"
WRAPPER_SCRIPT=~/automation/scripts/cron_wrapper.sh

# Check if the template exists
if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Error: Template script not found at $TEMPLATE_PATH."
    exit 1
fi

# Check if the scripts directory exists
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Scripts directory not found. Creating $SCRIPTS_DIR."
    mkdir -p "$SCRIPTS_DIR"
fi

# Copy the template to the new script path
cp "$TEMPLATE_PATH" "$NEW_SCRIPT_PATH"

# Make the new script executable
chmod +x "$NEW_SCRIPT_PATH"

# Confirm the script was created successfully
if [ -f "$NEW_SCRIPT_PATH" ]; then
    echo "New script created at $NEW_SCRIPT_PATH"
    
    # Ask if the user wants to edit the script immediately
    read -p "Do you want to edit the script now? (y/n): " edit_choice
    if [[ "$edit_choice" =~ ^[Yy]$ ]]; then
        nano "$NEW_SCRIPT_PATH"
    else
        echo "You can edit it later by running: nano $NEW_SCRIPT_PATH"
    fi
else
    echo "Error: Failed to create the new script."
    exit 1
fi

# Prompt for setting up a cron job
read -p "Do you want to set up a cron job for this script? (y/n): " cron_choice
if [[ "$cron_choice" =~ ^[Yy]$ ]]; then
    echo "Set up the cron job frequency:"
    echo "1. Every minute"
    echo "2. Every hour"
    echo "3. Daily"
    echo "4. Weekly"
    echo "5. Monthly"
    echo "6. Custom (enter your own cron schedule)"
    read -p "Choose an option (1-6): " frequency_choice
    
    case $frequency_choice in
        1) cron_schedule="* * * * *" ;;
        2) cron_schedule="0 * * * *" ;;
        3) cron_schedule="0 0 * * *" ;;
        4) cron_schedule="0 0 * * 0" ;;
        5) cron_schedule="0 0 1 * *" ;;
        6) 
            read -p "Enter your custom cron schedule (e.g., '0 5 * * 1'): " custom_schedule
            cron_schedule="$custom_schedule"
            ;;
        *) 
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
    
    # Add the cron job
    cron_job="$cron_schedule $WRAPPER_SCRIPT $NEW_SCRIPT_PATH"
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    
    # Log the cron job creation
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Added cron job: $cron_job" >> "$LOG_FILE"
    echo "Cron job added successfully. Logged to $LOG_FILE."
else
    echo "Cron job setup skipped."
fi
```
---

### **7. Backup and Recovery**
- **Backup Cron Configurations:**
  Schedule a cron job to back up the current crontab:
  ```bash
  crontab -l > ~/automation/backups/crontab_backup_$(date +"%Y%m%d").txt
  ```
- **Backup Scripts:**
  Create a tarball of all scripts periodically:
  ```bash
  tar -czf ~/automation/backups/scripts_backup_$(date +"%Y%m%d").tar.gz ~/automation/scripts/
  ```

---

### **8. Monitor Automation Health**
Set up monitoring to ensure everything runs smoothly.

#### Example: Daily Summary of Logs:
1. Create a summary script (`~/automation/scripts/log_summary.sh`):
   ```bash
   #!/bin/bash
   LOG_DIR=~/automation/logs
   SUMMARY_FILE=~/automation/logs/daily_summary.log

   echo "Daily Log Summary - $(date)" > "$SUMMARY_FILE"
   for log in "$LOG_DIR"/*.log; do
       echo "Log: $(basename "$log")" >> "$SUMMARY_FILE"
       tail -n 5 "$log" >> "$SUMMARY_FILE"
       echo "------------------------" >> "$SUMMARY_FILE"
   done

   mail -s "Daily Automation Summary" your_email@example.com < "$SUMMARY_FILE"
   ```

2. Add a cron job to run the summary script daily:
   ```bash
   0 6 * * * ~/automation/scripts/log_summary.sh
   ```

---

### **9. Documentation**
Maintain documentation for each script and cron job in a README file:
```bash
~/automation/README.md
```

#### Example Entry:
```markdown
## Script: my_new_script.sh
- **Purpose:** Backs up database daily.
- **Location:** ~/automation/scripts/my_new_script.sh
- **Cron Schedule:** 0 2 * * *
- **Logs:** ~/automation/logs/my_new_script.log
- **Dependencies:** env.sh (database credentials)
```

---

### **10. Security Best Practices**
- **Limit Permissions:**
  - Ensure scripts are executable only by the owner:
    ```bash
    chmod 700 ~/automation/scripts/*
    ```
- **Protect Sensitive Data:**
  - Use environment variables in `env.sh` instead of hardcoding credentials in scripts.
  - Restrict access to `env.sh`:
    ```bash
    chmod 600 ~/automation/configs/env.sh
    ```

---

### **11. Periodic Maintenance**
- **Review and Test Scripts:**
  Test all scripts manually at least once a month.
- **Clean Up Old Logs:**
  Use `logrotate` or a script to delete logs older than 30 days:
  ```bash
  find ~/automation/logs/ -type f -mtime +30 -delete
  ```

---

This process ensures a well-organized, secure, and maintainable setup for managing automation scripts and cron jobs. Let me know if you’d like any part expanded!
