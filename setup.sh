#!/bin/bash

# setup.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored status messages
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to create directory if it doesn't exist
create_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_status "${GREEN}" "Created directory: $dir"
    else
        print_status "${YELLOW}" "Directory already exists: $dir"
    fi
}

# Function to create a basic .env file if it doesn't exist
create_env_file() {
    local env_file=".env"
    if [ ! -f "$env_file" ]; then
        cat > "$env_file" << EOL
# Local static IP address of your host machine
LOCAL_IP=192.168.1.x

# Base directory for all services
ROOT_DIR=${HOME}
DATA_DIR=${HOME}

# Timezone
TIMEZONE=America/New_York

# Cloudflare Tunnel
TUNNEL_TOKEN=your_tunnel_token

EOL
        print_status "${GREEN}" "Created .env file with default values"
        print_status "${YELLOW}" "Please update the .env file with your actual values"
    else
        print_status "${YELLOW}" ".env file already exists"
    fi
}

# Function to create a basic MQTT configuration
create_mqtt_config() {
    local config_file="$1/config/mosquitto.conf"
    if [ ! -f "$config_file" ]; then
        mkdir -p "$(dirname "$config_file")"
        cat > "$config_file" << EOL
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883
allow_anonymous true
EOL
        print_status "${GREEN}" "Created MQTT configuration file"
    else
        print_status "${YELLOW}" "MQTT configuration file already exists"
    fi
}

# Main setup script
main() {
    print_status "${GREEN}" "Starting setup for Docker Compose environment..."

    # Create base directory structure
    BASE_DIR="${HOME}/home_assistant"
    
    # Create main directories
    create_dir "$BASE_DIR/config"
    create_dir "$BASE_DIR/nodered"
    create_dir "$BASE_DIR/pihole/etc-pihole"
    create_dir "$BASE_DIR/pihole/etc-dnsmasq.d"
    create_dir "$BASE_DIR/go2rtc"
    create_dir "$BASE_DIR/actual-budget"
    create_dir "$BASE_DIR/ssl_certs"
    create_dir "$BASE_DIR/mosquitto/config"
    create_dir "$BASE_DIR/mosquitto/data"
    create_dir "$BASE_DIR/mosquitto/log"
    create_dir "$BASE_DIR/whisper_models"
    create_dir "$BASE_DIR/whisper_data"

    # Create MQTT configuration
    create_mqtt_config "$BASE_DIR/mosquitto"

    # Create .env file
    create_env_file

    # Set appropriate permissions
    print_status "${GREEN}" "Setting permissions..."
    chmod -R 755 "$BASE_DIR"
    chmod 600 "$BASE_DIR/mosquitto/config/mosquitto.conf" 2>/dev/null || true

    print_status "${GREEN}" "Setup completed successfully!"
    print_status "${YELLOW}" "Remember to:"
    echo "1. Update the .env file with your actual values"
    echo "2. Create SSL certificates for Actual Budget if needed"
    echo "3. Configure Home Assistant secrets and configuration"
}

# Run the script
main

# Exit with success
exit 0
