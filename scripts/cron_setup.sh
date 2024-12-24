#!/bin/bash

# Variables
REPO_URL="https://github.com/yourusername/automation-setup.git"
BASE_DIR=~/automation
LOG_FILE="$BASE_DIR/logs/setup.log"

# Log function
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

# Ensure necessary tools are installed
install_dependencies() {
    log "Installing dependencies..."
    sudo apt update
    sudo apt install -y git nano logrotate
    log "Dependencies installed."
}

# Clone the repository
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

# Set up directory structure
setup_directories() {
    log "Setting up directory structure..."
    mkdir -p "$BASE_DIR/scripts" "$BASE_DIR/logs" "$BASE_DIR/configs" "$BASE_DIR/backups"
    log "Directory structure set up."
}

# Configure environment variables
configure_environment() {
    log "Configuring environment variables..."
    if [ -f "$BASE_DIR/configs/env.sh" ]; then
        source "$BASE_DIR/configs/env.sh"
        log "Environment variables configured."
    else
        log "Error: env.sh not found in configs. Please check your repository."
        exit 1
    fi
}

# Install logrotate configuration
setup_logrotate() {
    log "Setting up logrotate..."
    if [ -f "$BASE_DIR/logrotate/automation" ]; then
        sudo cp "$BASE_DIR/logrotate/automation" /etc/logrotate.d/automation
        log "Logrotate configuration installed."
    else
        log "Error: Logrotate configuration not found. Skipping."
    fi
}

# Add example cron jobs
setup_cron_jobs() {
    log "Adding example cron jobs..."
    CRON_JOB="* * * * * $BASE_DIR/scripts/cron_wrapper.sh $BASE_DIR/scripts/example_script.sh"
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    log "Cron job added: $CRON_JOB"
}

# Run setup steps
main() {
    log "Starting automation setup..."
    install_dependencies
    clone_repository
    setup_directories
    configure_environment
    setup_logrotate
    setup_cron_jobs
    log "Automation setup completed."
}

main
