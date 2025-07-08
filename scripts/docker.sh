#!/bin/bash

# ============================================================================= #
#                           DOCKER MANAGEMENT FUNCTIONS                        #
# ============================================================================= #

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if Docker is running
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        return 1
    fi
    
    return 0
}

# Function to confirm dangerous operations
confirm_action() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Operation cancelled${NC}"
        return 1
    fi
    return 0
}

# ========================== CONTAINER FUNCTIONS ============================= #

# Stop all running containers
docker_stop_all() {
    echo -e "${BLUE}Stopping all running containers...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    local running_containers=$(docker ps -q)
    
    if [ -z "$running_containers" ]; then
        echo -e "${GREEN}No running containers found${NC}"
        return 0
    fi
    
    if confirm_action "This will stop $(echo "$running_containers" | wc -l) running container(s)."; then
        docker stop $running_containers
        echo -e "${GREEN}All containers stopped successfully${NC}"
    fi
}

# Remove all containers (stopped and running)
docker_remove_all_containers() {
    echo -e "${BLUE}Removing all containers...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    local all_containers=$(docker ps -aq)
    
    if [ -z "$all_containers" ]; then
        echo -e "${GREEN}No containers found${NC}"
        return 0
    fi
    
    if confirm_action "This will remove $(echo "$all_containers" | wc -l) container(s) (including running ones)."; then
        # Stop running containers first
        local running_containers=$(docker ps -q)
        if [ -n "$running_containers" ]; then
            echo -e "${YELLOW}Stopping running containers first...${NC}"
            docker stop $running_containers
        fi
        
        # Remove all containers
        docker rm $all_containers
        echo -e "${GREEN}All containers removed successfully${NC}"
    fi
}

# Remove only stopped containers
docker_remove_stopped_containers() {
    echo -e "${BLUE}Removing stopped containers...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    local stopped_containers=$(docker ps -aq --filter "status=exited")
    
    if [ -z "$stopped_containers" ]; then
        echo -e "${GREEN}No stopped containers found${NC}"
        return 0
    fi
    
    docker rm $stopped_containers
    echo -e "${GREEN}Stopped containers removed successfully${NC}"
}

# ============================= IMAGE FUNCTIONS ============================== #

# Remove all images
docker_remove_all_images() {
    echo -e "${BLUE}Removing all images...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    local all_images=$(docker images -aq)
    
    if [ -z "$all_images" ]; then
        echo -e "${GREEN}No images found${NC}"
        return 0
    fi
    
    if confirm_action "This will remove $(echo "$all_images" | wc -l) image(s)."; then
        docker rmi -f $all_images
        echo -e "${GREEN}All images removed successfully${NC}"
    fi
}

# Remove dangling images
docker_remove_dangling_images() {
    echo -e "${BLUE}Removing dangling images...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    local dangling_images=$(docker images -f "dangling=true" -q)
    
    if [ -z "$dangling_images" ]; then
        echo -e "${GREEN}No dangling images found${NC}"
        return 0
    fi
    
    docker rmi $dangling_images
    echo -e "${GREEN}Dangling images removed successfully${NC}"
}

# Remove unused images
docker_remove_unused_images() {
    echo -e "${BLUE}Removing unused images...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    docker image prune -a -f
    echo -e "${GREEN}Unused images removed successfully${NC}"
}

# ============================= VOLUME FUNCTIONS ============================== #

# Remove all volumes
docker_remove_all_volumes() {
    echo -e "${BLUE}Removing all volumes...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    local all_volumes=$(docker volume ls -q)
    
    if [ -z "$all_volumes" ]; then
        echo -e "${GREEN}No volumes found${NC}"
        return 0
    fi
    
    if confirm_action "This will remove $(echo "$all_volumes" | wc -l) volume(s). This action is irreversible!"; then
        docker volume rm $all_volumes
        echo -e "${GREEN}All volumes removed successfully${NC}"
    fi
}

# Remove unused volumes
docker_remove_unused_volumes() {
    echo -e "${BLUE}Removing unused volumes...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    docker volume prune -f
    echo -e "${GREEN}Unused volumes removed successfully${NC}"
}

# ============================= NETWORK FUNCTIONS ============================= #

# Remove all custom networks
docker_remove_all_networks() {
    echo -e "${BLUE}Removing all custom networks...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    # Get custom networks (exclude default networks: bridge, host, none)
    local custom_networks=$(docker network ls --filter type=custom -q)
    
    if [ -z "$custom_networks" ]; then
        echo -e "${GREEN}No custom networks found${NC}"
        return 0
    fi
    
    if confirm_action "This will remove $(echo "$custom_networks" | wc -l) custom network(s)."; then
        docker network rm $custom_networks
        echo -e "${GREEN}All custom networks removed successfully${NC}"
    fi
}

# Remove unused networks
docker_remove_unused_networks() {
    echo -e "${BLUE}Removing unused networks...${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    docker network prune -f
    echo -e "${GREEN}Unused networks removed successfully${NC}"
}

# ============================= SYSTEM FUNCTIONS ============================== #

# Complete Docker cleanup
docker_cleanup_all() {
    echo -e "${RED}=== COMPLETE DOCKER CLEANUP ===${NC}"
    echo -e "${YELLOW}This will remove:${NC}"
    echo -e "  • All containers (running and stopped)"
    echo -e "  • All images"
    echo -e "  • All volumes"
    echo -e "  • All custom networks"
    echo -e "  • All build cache"
    echo
    
    if ! check_docker; then
        return 1
    fi
    
    if confirm_action "This is a destructive operation that will remove ALL Docker data!"; then
        echo -e "${BLUE}Starting complete cleanup...${NC}"
        
        # Stop all containers
        local running_containers=$(docker ps -q)
        if [ -n "$running_containers" ]; then
            echo -e "${YELLOW}Stopping all running containers...${NC}"
            docker stop $running_containers
        fi
        
        # Use Docker system prune with --all flag
        docker system prune -a -f --volumes
        
        echo -e "${GREEN}Complete Docker cleanup finished!${NC}"
    fi
}

# Safe cleanup (removes only unused resources)
docker_cleanup_safe() {
    echo -e "${BLUE}=== SAFE DOCKER CLEANUP ===${NC}"
    echo -e "${YELLOW}This will remove only unused resources:${NC}"
    echo -e "  • Stopped containers"
    echo -e "  • Dangling images"
    echo -e "  • Unused volumes"
    echo -e "  • Unused networks"
    echo -e "  • Build cache"
    echo
    
    if ! check_docker; then
        return 1
    fi
    
    docker system prune -f --volumes
    echo -e "${GREEN}Safe cleanup completed!${NC}"
}

# Show Docker system information
docker_info() {
    echo -e "${BLUE}=== DOCKER SYSTEM INFORMATION ===${NC}"
    
    if ! check_docker; then
        return 1
    fi
    
    echo -e "${YELLOW}Containers:${NC}"
    echo "  Running: $(docker ps -q | wc -l)"
    echo "  Stopped: $(docker ps -aq --filter "status=exited" | wc -l)"
    echo "  Total: $(docker ps -aq | wc -l)"
    
    echo -e "${YELLOW}Images:${NC}"
    echo "  Total: $(docker images -q | wc -l)"
    echo "  Dangling: $(docker images -f "dangling=true" -q | wc -l)"
    
    echo -e "${YELLOW}Volumes:${NC}"
    echo "  Total: $(docker volume ls -q | wc -l)"
    
    echo -e "${YELLOW}Networks:${NC}"
    echo "  Total: $(docker network ls -q | wc -l)"
    echo "  Custom: $(docker network ls --filter type=custom -q | wc -l)"
    
    echo
    echo -e "${YELLOW}Disk Usage:${NC}"
    docker system df
}

# Show help
docker_help() {
    echo -e "${BLUE}=== DOCKER MANAGEMENT FUNCTIONS ===${NC}"
    echo
    echo -e "${YELLOW}Container Functions:${NC}"
    echo "  docker_stop_all                    - Stop all running containers"
    echo "  docker_remove_all_containers       - Remove all containers (running and stopped)"
    echo "  docker_remove_stopped_containers   - Remove only stopped containers"
    echo
    echo -e "${YELLOW}Image Functions:${NC}"
    echo "  docker_remove_all_images           - Remove all images"
    echo "  docker_remove_dangling_images      - Remove dangling images"
    echo "  docker_remove_unused_images        - Remove unused images"
    echo
    echo -e "${YELLOW}Volume Functions:${NC}"
    echo "  docker_remove_all_volumes          - Remove all volumes"
    echo "  docker_remove_unused_volumes       - Remove unused volumes"
    echo
    echo -e "${YELLOW}Network Functions:${NC}"
    echo "  docker_remove_all_networks         - Remove all custom networks"
    echo "  docker_remove_unused_networks      - Remove unused networks"
    echo
    echo -e "${YELLOW}System Functions:${NC}"
    echo "  docker_cleanup_all                 - Complete cleanup (removes everything)"
    echo "  docker_cleanup_safe                - Safe cleanup (removes only unused resources)"
    echo "  docker_info                        - Show Docker system information"
    echo "  docker_help                        - Show this help message"
    echo
    echo -e "${GREEN}Usage: Source this file and call the functions directly${NC}"
    echo -e "${GREEN}Example: source ./scripts/docker.sh && docker_info${NC}"
}

# Export functions so they can be used when sourced
export -f check_docker confirm_action
export -f docker_stop_all docker_remove_all_containers docker_remove_stopped_containers
export -f docker_remove_all_images docker_remove_dangling_images docker_remove_unused_images
export -f docker_remove_all_volumes docker_remove_unused_volumes
export -f docker_remove_all_networks docker_remove_unused_networks
export -f docker_cleanup_all docker_cleanup_safe docker_info docker_help

# If script is executed directly, show help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    docker_help
fi
