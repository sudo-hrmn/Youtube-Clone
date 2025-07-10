#!/bin/bash

# GitHub Container Registry Setup Script
# Professional setup for YouTube Clone project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USERNAME="sudo-hrmn"
GITHUB_REPO="Youtube-Clone"
IMAGE_NAME="youtube-clone"
NAMESPACE="youtube-clone-v1"
SECRET_NAME="github-container-registry"

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "docker is not installed"
        exit 1
    fi
    
    # Check if we can connect to Kubernetes cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Create namespace if it doesn't exist
create_namespace() {
    log_info "Creating namespace if it doesn't exist..."
    
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_info "Namespace '$NAMESPACE' already exists"
    else
        kubectl create namespace "$NAMESPACE"
        log_success "Namespace '$NAMESPACE' created"
    fi
}

# Create GitHub Container Registry secret
create_registry_secret() {
    log_header "GitHub Container Registry Secret Setup"
    
    # Check if GITHUB_TOKEN is set
    if [ -z "$GITHUB_TOKEN" ]; then
        log_error "GITHUB_TOKEN environment variable is not set"
        echo "Please set your GitHub Personal Access Token:"
        echo "export GITHUB_TOKEN=your_github_token_here"
        exit 1
    fi
    
    # Check if EMAIL is set
    if [ -z "$EMAIL" ]; then
        log_warning "EMAIL environment variable is not set, using default"
        EMAIL="$GITHUB_USERNAME@users.noreply.github.com"
    fi
    
    log_info "Creating GitHub Container Registry secret..."
    
    # Delete existing secret if it exists
    kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" 2>/dev/null || true
    
    # Create the secret
    kubectl create secret docker-registry "$SECRET_NAME" \
        --docker-server=ghcr.io \
        --docker-username="$GITHUB_USERNAME" \
        --docker-password="$GITHUB_TOKEN" \
        --docker-email="$EMAIL" \
        --namespace="$NAMESPACE"
    
    log_success "GitHub Container Registry secret created"
}

# Build and push Docker image
build_and_push_image() {
    log_header "Building and Pushing Docker Image"
    
    local image_tag="ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest"
    local build_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    
    log_info "Building Docker image: $image_tag"
    
    # Build the image with build args
    docker build \
        --build-arg BUILD_DATE="$build_date" \
        --build-arg GIT_COMMIT="$git_commit" \
        --build-arg VERSION="v1.0.0" \
        -t "$image_tag" \
        .
    
    log_success "Docker image built successfully"
    
    # Login to GitHub Container Registry
    log_info "Logging into GitHub Container Registry..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin
    
    # Push the image
    log_info "Pushing image to GitHub Container Registry..."
    docker push "$image_tag"
    
    log_success "Image pushed successfully: $image_tag"
}

# Update Kubernetes manifests
update_manifests() {
    log_header "Updating Kubernetes Manifests"
    
    local image_tag="ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME:latest"
    
    # Update deployment.yaml
    if [ -f "kubernetes/base/deployment.yaml" ]; then
        log_info "Updating deployment.yaml with new image..."
        sed -i "s|image: .*|image: $image_tag|g" kubernetes/base/deployment.yaml
        log_success "deployment.yaml updated"
    fi
    
    # Update kustomization.yaml
    if [ -f "kubernetes/base/kustomization.yaml" ]; then
        log_info "Updating kustomization.yaml with new image..."
        sed -i "s|newName: .*|newName: ghcr.io/$GITHUB_USERNAME/$IMAGE_NAME|g" kubernetes/base/kustomization.yaml
        log_success "kustomization.yaml updated"
    fi
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    log_header "Deploying to Kubernetes"
    
    log_info "Applying Kubernetes manifests..."
    
    # Apply base manifests
    kubectl apply -k kubernetes/base/
    
    # Wait for deployment to be ready
    log_info "Waiting for deployment to be ready..."
    kubectl rollout status deployment/youtube-clone-deployment -n "$NAMESPACE" --timeout=300s
    
    log_success "Deployment completed successfully"
}

# Show deployment status
show_status() {
    log_header "Deployment Status"
    
    echo -e "${BLUE}=== Pods ===${NC}"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    echo -e "\n${BLUE}=== Services ===${NC}"
    kubectl get services -n "$NAMESPACE"
    
    echo -e "\n${BLUE}=== Ingress ===${NC}"
    kubectl get ingress -n "$NAMESPACE" 2>/dev/null || echo "No ingress found"
    
    echo -e "\n${BLUE}=== Secrets ===${NC}"
    kubectl get secrets -n "$NAMESPACE"
    
    # Show access information
    local nodeport=$(kubectl get service youtube-clone-nodeport -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
    
    echo -e "\n${GREEN}=== Access Information ===${NC}"
    echo "NodePort: http://localhost:$nodeport"
    echo "Port Forward: kubectl port-forward service/youtube-clone-service 8080:80 -n $NAMESPACE"
    echo "Then access: http://localhost:8080"
}

# Main function
main() {
    log_header "YouTube Clone - GitHub Container Registry Setup"
    
    case "${1:-all}" in
        "prerequisites")
            check_prerequisites
            ;;
        "namespace")
            create_namespace
            ;;
        "secret")
            check_prerequisites
            create_namespace
            create_registry_secret
            ;;
        "build")
            check_prerequisites
            build_and_push_image
            ;;
        "deploy")
            check_prerequisites
            create_namespace
            deploy_to_kubernetes
            show_status
            ;;
        "status")
            show_status
            ;;
        "all")
            check_prerequisites
            create_namespace
            create_registry_secret
            build_and_push_image
            update_manifests
            deploy_to_kubernetes
            show_status
            ;;
        "help")
            echo "GitHub Container Registry Setup Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  all           - Run complete setup (default)"
            echo "  prerequisites - Check prerequisites"
            echo "  namespace     - Create namespace"
            echo "  secret        - Create registry secret"
            echo "  build         - Build and push image"
            echo "  deploy        - Deploy to Kubernetes"
            echo "  status        - Show deployment status"
            echo "  help          - Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  GITHUB_TOKEN  - GitHub Personal Access Token (required)"
            echo "  EMAIL         - Email for Docker registry (optional)"
            echo ""
            echo "Example:"
            echo "  export GITHUB_TOKEN=ghp_xxxxxxxxxxxx"
            echo "  export EMAIL=your-email@example.com"
            echo "  $0 all"
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
