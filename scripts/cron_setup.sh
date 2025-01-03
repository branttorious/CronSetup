#!/bin/bash

# Variables
REPO_URL="https://github.com/yourusername/your-repository.git"
BASE_DIR=~/automation
LOG_FILE="$BASE_DIR/logs/setup.log"
CONFIGS_DIR="$BASE_DIR/configs"
SCRIPTS_DIR="$BASE_DIR/scripts"
BACKUPS_DIR="$BASE_DIR/backups"

# Log function
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

# Step 1: Install Dependencies
install_dependencies() {
    log "Installing dependencies..."
    sudo apt update
    sudo apt install -y git nano logrotate mailutils
    log "Dependencies installed."
}

# Step 2: Clone Repository
clone_repository() {
    log "Cloning repository from $REPO_URL..."
    if [ -d "$BASE_DIR" ]; then
        log "Automation directory already exists. Pulling latest changes."
        cd "$BASE_DIR" && git pull
    else
        git clone "$REPO_URL" "$BASE_DIR"
    fi
    log "Repository cloned to $BASE_DIR."
}

# Step 3: Set Up Directory Structure
setup_directories() {
    log "Setting up directory structure..."
    mkdir -p "$SCRIPTS_DIR" "$CONFIGS_DIR" "$BACKUPS_DIR" "$BASE_DIR/logs"
    log "Directory structure set up."
}

# Step 4: Configure Environment Variables
configure_environment() {
    log "Configuring environment variables..."
    if [ -f "$CONFIGS_DIR/env.sh" ]; then
        source "$CONFIGS_DIR/env.sh"
        log "Environment variables configured."
    else
        log "Error: env.sh not found in configs directory."
        exit 1
    fi
}

# Step 5: Configure Logrotate
setup_logrotate() {
    log "Setting up logrotate..."
    if [ -f "$BASE_DIR/logrotate/automation" ]; then
        sudo cp "$BASE_DIR/logrotate/automation" /etc/logrotate.d/automation
        log "Logrotate configuration installed."
    else
        log "Error: Logrotate configuration not found. Skipping."
    fi
}

# Step 6: Set Up Example Cron Jobs
setup_cron_jobs() {
    log "Adding example cron jobs..."
    CRON_JOB="0 6 * * * $SCRIPTS_DIR/log_summary.sh"
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    log "Example cron job added: $CRON_JOB"
}

# Step 7: Test Setup
test_setup() {
    log "Testing setup..."
    if [ -d "$BASE_DIR" ] && [ -f "$CONFIGS_DIR/env.sh" ]; then
        log "Setup completed successfully."
    else
        log "Error during setup. Check logs for details."
        exit 1
    fi
}

# Main Script
main() {
    log "Starting automation setup..."
    install_dependencies
    clone_repository
    setup_directories
    configure_environment
    setup_logrotate
    setup_cron_jobs
    test_setup
    log "Automation setup completed successfully!"
}

main
