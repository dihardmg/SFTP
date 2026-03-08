#!/bin/bash

# ============================================
# SFTP Servers Management Script
# ============================================
# This script manages SFTP source and target servers
# for testing the Sync Engine application.
#
# Usage: ./manage-sftp.sh [start|stop|status|restart|logs]
# ============================================

SFTP_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SFTP_HOME}/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# Functions
# ============================================

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        echo "Please install Docker first"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}Error: Docker Compose is not installed${NC}"
        echo "Please install Docker Compose first"
        exit 1
    fi
}

# Get docker compose command
get_docker_compose_cmd() {
    if docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo "docker-compose"
    fi
}

# Start SFTP servers
start_servers() {
    echo -e "${GREEN}Starting SFTP servers...${NC}"
    cd "$SFTP_HOME"

    # Create target_data directory if not exists
    if [ ! -d "target_data/claim_evidence" ]; then
        echo "Creating target_data directories..."
        mkdir -p target_data/claim_evidence
        mkdir -p target_data/archive
        echo -e "${GREEN}✓ Target directories created${NC}"
    fi

    # Start servers
    $(get_docker_compose_cmd) -f "$COMPOSE_FILE" up -d

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SFTP servers started successfully${NC}"
        echo ""
        echo "Server Status:"
        show_status
        echo ""
        echo "Connection Details:"
        echo "  Source SFTP: localhost:2222 (user: tester, pass: password123)"
        echo "  Target SFTP: localhost:2223 (user: tester, pass: password123)"
    else
        echo -e "${RED}✗ Failed to start SFTP servers${NC}"
        exit 1
    fi
}

# Stop SFTP servers
stop_servers() {
    echo -e "${YELLOW}Stopping SFTP servers...${NC}"
    cd "$SFTP_HOME"

    $(get_docker_compose_cmd) -f "$COMPOSE_FILE" down

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SFTP servers stopped successfully${NC}"
    else
        echo -e "${RED}✗ Failed to stop SFTP servers${NC}"
        exit 1
    fi
}

# Restart SFTP servers
restart_servers() {
    echo -e "${YELLOW}Restarting SFTP servers...${NC}"
    stop_servers
    sleep 2
    start_servers
}

# Show status of SFTP servers
show_status() {
    echo ""
    echo "SFTP Servers Status:"
    echo "===================="

    # Check source server
    if docker ps | grep -q "sftp_source_server"; then
        echo -e "  Source Server: ${GREEN}Running${NC} (localhost:2222)"
    else
        echo -e "  Source Server: ${RED}Stopped${NC}"
    fi

    # Check target server
    if docker ps | grep -q "sftp_target_server"; then
        echo -e "  Target Server: ${GREEN}Running${NC} (localhost:2223)"
    else
        echo -e "  Target Server: ${RED}Stopped${NC}"
    fi

    echo ""
    echo "Container Details:"
    docker ps --filter "name=sftp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Show logs from SFTP servers
show_logs() {
    echo "Showing SFTP servers logs (Ctrl+C to exit)..."
    cd "$SFTP_HOME"
    $(get_docker_compose_cmd) -f "$COMPOSE_FILE" logs -f
}

# Show connection test info
show_connection_info() {
    echo ""
    echo "SFTP Connection Details:"
    echo "========================"
    echo ""
    echo "Source SFTP Server:"
    echo "  Host: localhost"
    echo "  Port: 2222"
    echo "  Username: tester"
    echo "  Password: password123"
    echo "  Source Path: /home/tester/claim_evidence"
    echo "  Archive Path: /home/tester/archive"
    echo ""
    echo "Target SFTP Server:"
    echo "  Host: localhost"
    echo "  Port: 2223"
    echo "  Username: tester"
    echo "  Password: password123"
    echo "  Target Path: /home/tester/claim_evidence"
    echo ""
    echo "Test Connection:"
    echo "  # Test source server"
    echo "  sftp -P 2222 tester@localhost"
    echo "  # Test target server"
    echo "  sftp -P 2223 tester@localhost"
    echo ""
}

# ============================================
# Main
# ============================================

# Check Docker
check_docker

# Parse command
case "${1:-start}" in
    start)
        start_servers
        ;;
    stop)
        stop_servers
        ;;
    restart)
        restart_servers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    info)
        show_connection_info
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|info}"
        echo ""
        echo "Commands:"
        echo "  start    - Start SFTP servers"
        echo "  stop     - Stop SFTP servers"
        echo "  restart  - Restart SFTP servers"
        echo "  status   - Show servers status"
        echo "  logs     - Show servers logs"
        echo "  info     - Show connection details"
        exit 1
        ;;
esac
