#!/bin/bash

# YouTube Clone V1 - Kind Cluster Deployment Script
# Professional deployment automation for Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="youtube-clone-v1"
NAMESPACE="youtube-clone-v1"
IMAGE_NAME="youtube-clone:latest"

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

# Check if Kind cluster exists
check_cluster() {
    log_info "Checking Kind cluster status..."
    if kind get clusters | grep -q "$CLUSTER_NAME"; then
        log_success "Kind cluster '$CLUSTER_NAME' is running"
        return 0
    else
        log_error "Kind cluster '$CLUSTER_NAME' not found"
        return 1
    fi
}

# Build Docker image
build_image() {
    log_info "Building Docker image..."
    if docker build -t "$IMAGE_NAME" .; then
        log_success "Docker image built successfully"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Load image into Kind cluster
load_image() {
    log_info "Loading image into Kind cluster..."
    if kind load docker-image "$IMAGE_NAME" --name "$CLUSTER_NAME"; then
        log_success "Image loaded into Kind cluster"
    else
        log_error "Failed to load image into Kind cluster"
        exit 1
    fi
}

# Deploy application
deploy_app() {
    log_info "Deploying YouTube Clone to Kubernetes..."
    
    # Switch to Kind context
    kubectl config use-context "kind-$CLUSTER_NAME"
    
    # Apply deployment
    if kubectl apply -f k8s-deployment.yaml; then
        log_success "Deployment applied successfully"
    else
        log_error "Failed to apply deployment"
        exit 1
    fi
    
    # Wait for deployment to be ready
    log_info "Waiting for deployment to be ready..."
    if kubectl rollout status deployment/youtube-clone-deployment -n "$NAMESPACE" --timeout=300s; then
        log_success "Deployment is ready"
    else
        log_error "Deployment failed to become ready"
        exit 1
    fi
}

# Check deployment status
check_status() {
    log_info "Checking deployment status..."
    
    echo -e "\n${BLUE}=== PODS ===${NC}"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    echo -e "\n${BLUE}=== SERVICES ===${NC}"
    kubectl get services -n "$NAMESPACE"
    
    echo -e "\n${BLUE}=== INGRESS ===${NC}"
    kubectl get ingress -n "$NAMESPACE" 2>/dev/null || echo "No ingress found"
    
    echo -e "\n${BLUE}=== HPA ===${NC}"
    kubectl get hpa -n "$NAMESPACE" 2>/dev/null || echo "No HPA found"
}

# Show access information
show_access_info() {
    log_info "Access Information:"
    echo -e "\n${GREEN}1. NodePort Access:${NC}"
    echo "   curl http://localhost:30000"
    
    echo -e "\n${GREEN}2. Port Forward Access:${NC}"
    echo "   kubectl port-forward service/youtube-clone-service 8080:80 -n $NAMESPACE"
    echo "   curl http://localhost:8080"
    
    echo -e "\n${GREEN}3. Ingress Access:${NC}"
    echo "   Add to /etc/hosts: 127.0.0.1 youtube-clone.local"
    echo "   curl http://youtube-clone.local"
}

# Main deployment function
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  YouTube Clone V1 - Kind Deployment  ${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    
    # Check if cluster exists
    if ! check_cluster; then
        log_error "Please create the Kind cluster first:"
        echo "kind create cluster --config=kind-cluster-simple.yaml"
        exit 1
    fi
    
    # Build and load image
    build_image
    load_image
    
    # Deploy application
    deploy_app
    
    # Check status
    check_status
    
    # Show access information
    show_access_info
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}     Deployment Completed Successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# Handle script arguments
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "status")
        check_status
        ;;
    "build")
        build_image
        load_image
        ;;
    "clean")
        log_info "Cleaning up deployment..."
        kubectl delete -f k8s-deployment.yaml 2>/dev/null || true
        log_success "Cleanup completed"
        ;;
    "help")
        echo "Usage: $0 [deploy|status|build|clean|help]"
        echo ""
        echo "Commands:"
        echo "  deploy  - Build image and deploy to Kind cluster (default)"
        echo "  status  - Show deployment status"
        echo "  build   - Build and load Docker image only"
        echo "  clean   - Remove deployment from cluster"
        echo "  help    - Show this help message"
        ;;
    *)
        log_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
