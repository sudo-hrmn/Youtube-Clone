#!/bin/bash

# ArgoCD Applications Deployment Script
# Professional App of Apps deployment for YouTube Clone

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
ARGOCD_NAMESPACE="argocd"
PROJECT_NAME="youtube-clone-project"
PARENT_APP="youtube-clone-platform"

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
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    # Check if ArgoCD is running
    if ! kubectl get namespace $ARGOCD_NAMESPACE &> /dev/null; then
        log_error "ArgoCD namespace not found. Please install ArgoCD first."
        exit 1
    fi
    
    # Check if ArgoCD server is running
    if ! kubectl get pods -n $ARGOCD_NAMESPACE -l app.kubernetes.io/name=argocd-server | grep -q Running; then
        log_error "ArgoCD server is not running"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Deploy ArgoCD Project
deploy_project() {
    log_header "Deploying ArgoCD Project"
    
    log_info "Creating YouTube Clone project..."
    kubectl apply -f argocd-apps/youtube-clone-project.yaml
    
    # Wait for project to be created
    log_info "Waiting for project to be ready..."
    kubectl wait --for=condition=Ready appproject/$PROJECT_NAME -n $ARGOCD_NAMESPACE --timeout=60s || true
    
    log_success "ArgoCD project deployed"
}

# Deploy Parent Application (App of Apps)
deploy_parent_app() {
    log_header "Deploying Parent Application (App of Apps)"
    
    log_info "Creating parent application: $PARENT_APP"
    kubectl apply -f argocd-apps/youtube-clone-app-of-apps.yaml
    
    # Wait for application to be created
    log_info "Waiting for parent application to be ready..."
    sleep 10
    
    log_success "Parent application deployed"
}

# Check application status
check_app_status() {
    log_header "Application Status"
    
    echo -e "${BLUE}=== ArgoCD Applications ===${NC}"
    kubectl get applications -n $ARGOCD_NAMESPACE -l app=youtube-clone
    
    echo -e "\n${BLUE}=== Application Details ===${NC}"
    if kubectl get application $PARENT_APP -n $ARGOCD_NAMESPACE &> /dev/null; then
        kubectl describe application $PARENT_APP -n $ARGOCD_NAMESPACE | grep -A 10 "Status:"
    fi
    
    echo -e "\n${BLUE}=== Child Applications ===${NC}"
    kubectl get applications -n $ARGOCD_NAMESPACE -l component
}

# Sync applications
sync_applications() {
    log_header "Syncing Applications"
    
    # Check if argocd CLI is available
    if command -v argocd &> /dev/null; then
        log_info "Using ArgoCD CLI to sync applications..."
        
        # Sync parent application
        argocd app sync $PARENT_APP --timeout 300
        
        # Sync child applications
        for app in youtube-clone-infrastructure youtube-clone-core youtube-clone-monitoring; do
            if kubectl get application $app -n $ARGOCD_NAMESPACE &> /dev/null; then
                log_info "Syncing $app..."
                argocd app sync $app --timeout 300
            fi
        done
        
        log_success "All applications synced"
    else
        log_warning "ArgoCD CLI not found. Applications will sync automatically."
        log_info "You can also sync manually via ArgoCD UI at: http://localhost:8080"
    fi
}

# Show access information
show_access_info() {
    log_header "Access Information"
    
    echo -e "${GREEN}=== ArgoCD UI Access ===${NC}"
    echo "URL: https://localhost:8080"
    echo "Username: admin"
    echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo 'XiKvXakNKAKa-j4J')"
    
    echo -e "\n${GREEN}=== Application URLs ===${NC}"
    echo "Parent App: https://localhost:8080/applications/$PARENT_APP"
    echo "Project: https://localhost:8080/settings/projects/$PROJECT_NAME"
    
    echo -e "\n${GREEN}=== Kubernetes Resources ===${NC}"
    echo "Namespace: youtube-clone-v1"
    echo "NodePort: http://localhost:30001"
    echo "Port Forward: kubectl port-forward service/youtube-clone-service 8080:80 -n youtube-clone-v1"
}

# Cleanup function
cleanup() {
    log_header "Cleanup Applications"
    
    log_warning "This will delete all YouTube Clone applications from ArgoCD"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deleting applications..."
        
        # Delete child applications first
        kubectl delete applications -n $ARGOCD_NAMESPACE -l app=youtube-clone,component 2>/dev/null || true
        
        # Delete parent application
        kubectl delete application $PARENT_APP -n $ARGOCD_NAMESPACE 2>/dev/null || true
        
        # Delete project
        kubectl delete appproject $PROJECT_NAME -n $ARGOCD_NAMESPACE 2>/dev/null || true
        
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Main function
main() {
    log_header "YouTube Clone - ArgoCD App of Apps Deployment"
    
    case "${1:-deploy}" in
        "prerequisites")
            check_prerequisites
            ;;
        "project")
            check_prerequisites
            deploy_project
            ;;
        "parent")
            check_prerequisites
            deploy_parent_app
            ;;
        "deploy")
            check_prerequisites
            deploy_project
            deploy_parent_app
            check_app_status
            show_access_info
            ;;
        "sync")
            check_prerequisites
            sync_applications
            ;;
        "status")
            check_app_status
            ;;
        "access")
            show_access_info
            ;;
        "cleanup")
            cleanup
            ;;
        "help")
            echo "ArgoCD App of Apps Deployment Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  deploy       - Deploy complete App of Apps structure (default)"
            echo "  prerequisites- Check prerequisites"
            echo "  project      - Deploy ArgoCD project only"
            echo "  parent       - Deploy parent application only"
            echo "  sync         - Sync all applications"
            echo "  status       - Show application status"
            echo "  access       - Show access information"
            echo "  cleanup      - Remove all applications"
            echo "  help         - Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 deploy"
            echo "  $0 status"
            echo "  $0 sync"
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
