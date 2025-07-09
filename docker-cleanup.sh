#!/bin/bash

# Docker Cleanup Script for YouTube Clone V1
# Professional Docker environment cleanup and optimization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

# Show current Docker usage
show_current_usage() {
    log_header "Current Docker Usage"
    
    echo -e "${BLUE}=== System Usage ===${NC}"
    docker system df
    
    echo -e "\n${BLUE}=== Running Containers ===${NC}"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    
    echo -e "\n${BLUE}=== All Images ===${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}"
    
    echo -e "\n${BLUE}=== Dangling Images ===${NC}"
    docker images -f "dangling=true" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" || echo "No dangling images found"
}

# Identify what to keep (essential containers/images)
identify_essential() {
    log_info "Identifying essential containers and images..."
    
    echo -e "${GREEN}Essential containers to KEEP:${NC}"
    echo "  ✅ youtube-clone-v1-control-plane (Kind cluster)"
    echo "  ✅ minikube (Minikube cluster)"
    echo "  ⚠️  youtube-clone-local (can be removed if not needed)"
    
    echo -e "\n${GREEN}Essential images to KEEP:${NC}"
    echo "  ✅ youtube-clone:latest (current application image)"
    echo "  ✅ kindest/node:v1.28.0 (Kind cluster node)"
    echo "  ✅ gcr.io/k8s-minikube/kicbase:v0.0.47 (Minikube base)"
    
    echo -e "\n${RED}Items to REMOVE:${NC}"
    echo "  ❌ Dangling images (old build artifacts)"
    echo "  ❌ Unused build cache"
    echo "  ❌ Unused volumes (if safe)"
    echo "  ❌ Old YouTube Clone containers (if not needed)"
}

# Remove dangling images
remove_dangling_images() {
    log_info "Removing dangling images..."
    
    local dangling_images=$(docker images -f "dangling=true" -q)
    if [ -n "$dangling_images" ]; then
        echo "Found dangling images: $dangling_images"
        docker rmi $dangling_images
        log_success "Dangling images removed"
    else
        log_info "No dangling images found"
    fi
}

# Remove build cache
remove_build_cache() {
    log_info "Removing Docker build cache..."
    
    local cache_size=$(docker system df | grep "Build Cache" | awk '{print $4}')
    if [ "$cache_size" != "0B" ]; then
        docker builder prune -f
        log_success "Build cache cleared (was: $cache_size)"
    else
        log_info "No build cache to clear"
    fi
}

# Remove unused volumes (with confirmation)
remove_unused_volumes() {
    log_info "Checking for unused volumes..."
    
    local unused_volumes=$(docker volume ls -f dangling=true -q)
    if [ -n "$unused_volumes" ]; then
        echo -e "${YELLOW}Found unused volumes:${NC}"
        docker volume ls -f dangling=true
        
        read -p "Remove unused volumes? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker volume prune -f
            log_success "Unused volumes removed"
        else
            log_info "Skipping volume cleanup"
        fi
    else
        log_info "No unused volumes found"
    fi
}

# Remove specific old containers (with confirmation)
remove_old_containers() {
    log_info "Checking for old YouTube Clone containers..."
    
    # Check if youtube-clone-local container should be removed
    if docker ps -a | grep -q "youtube-clone-local"; then
        echo -e "${YELLOW}Found youtube-clone-local container${NC}"
        docker ps -a | grep "youtube-clone-local"
        
        read -p "Remove youtube-clone-local container? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker stop youtube-clone-local 2>/dev/null || true
            docker rm youtube-clone-local 2>/dev/null || true
            log_success "youtube-clone-local container removed"
        else
            log_info "Keeping youtube-clone-local container"
        fi
    fi
}

# Clean up unused networks
remove_unused_networks() {
    log_info "Removing unused networks..."
    
    local unused_networks=$(docker network ls -f dangling=true -q)
    if [ -n "$unused_networks" ]; then
        docker network prune -f
        log_success "Unused networks removed"
    else
        log_info "No unused networks found"
    fi
}

# Comprehensive cleanup
comprehensive_cleanup() {
    log_header "Comprehensive Docker Cleanup"
    
    log_info "Starting comprehensive cleanup..."
    
    # Remove stopped containers
    log_info "Removing stopped containers..."
    docker container prune -f
    
    # Remove dangling images
    remove_dangling_images
    
    # Remove unused networks
    remove_unused_networks
    
    # Remove build cache
    remove_build_cache
    
    # Remove unused volumes (with confirmation)
    remove_unused_volumes
    
    log_success "Comprehensive cleanup completed"
}

# Show space saved
show_space_saved() {
    log_header "Cleanup Results"
    
    echo -e "${BLUE}=== Updated System Usage ===${NC}"
    docker system df
    
    echo -e "\n${BLUE}=== Remaining Images ===${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}"
    
    echo -e "\n${BLUE}=== Active Containers ===${NC}"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# Interactive cleanup
interactive_cleanup() {
    log_header "Interactive Docker Cleanup"
    
    show_current_usage
    echo
    identify_essential
    echo
    
    read -p "Proceed with cleanup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        comprehensive_cleanup
        remove_old_containers
        show_space_saved
    else
        log_info "Cleanup cancelled"
    fi
}

# Aggressive cleanup (removes everything non-essential)
aggressive_cleanup() {
    log_warning "AGGRESSIVE CLEANUP MODE"
    echo "This will remove:"
    echo "  - All stopped containers"
    echo "  - All dangling images"
    echo "  - All unused volumes"
    echo "  - All unused networks"
    echo "  - All build cache"
    echo
    
    read -p "Are you sure? This cannot be undone! (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Starting aggressive cleanup..."
        
        # Stop and remove youtube-clone-local if exists
        docker stop youtube-clone-local 2>/dev/null || true
        docker rm youtube-clone-local 2>/dev/null || true
        
        # System prune (removes everything unused)
        docker system prune -a -f --volumes
        
        log_success "Aggressive cleanup completed"
        show_space_saved
    else
        log_info "Aggressive cleanup cancelled"
    fi
}

# Main function
main() {
    case "${1:-interactive}" in
        "status")
            show_current_usage
            ;;
        "interactive")
            interactive_cleanup
            ;;
        "comprehensive")
            comprehensive_cleanup
            show_space_saved
            ;;
        "aggressive")
            aggressive_cleanup
            ;;
        "dangling")
            remove_dangling_images
            ;;
        "cache")
            remove_build_cache
            ;;
        "volumes")
            remove_unused_volumes
            ;;
        "help")
            echo "Docker Cleanup Script - YouTube Clone V1"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  status       - Show current Docker usage"
            echo "  interactive  - Interactive cleanup with confirmations (default)"
            echo "  comprehensive- Full cleanup keeping essential items"
            echo "  aggressive   - Remove everything non-essential (DANGEROUS)"
            echo "  dangling     - Remove only dangling images"
            echo "  cache        - Remove only build cache"
            echo "  volumes      - Remove only unused volumes"
            echo "  help         - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 status"
            echo "  $0 interactive"
            echo "  $0 comprehensive"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
