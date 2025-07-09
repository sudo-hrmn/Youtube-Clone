#!/bin/bash

# ArgoCD Manager Script for YouTube Clone V1
# Professional ArgoCD management and GitOps automation

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
APP_NAME="youtube-clone-v1"
APP_NAMESPACE="youtube-clone-v1"
NODEPORT_URL="http://localhost:30080"
ADMIN_PASSWORD="XiKvXakNKAKa-j4J"

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

# Check ArgoCD status
check_argocd_status() {
    log_info "Checking ArgoCD status..."
    
    if kubectl get namespace $ARGOCD_NAMESPACE >/dev/null 2>&1; then
        log_success "ArgoCD namespace exists"
    else
        log_error "ArgoCD namespace not found"
        return 1
    fi
    
    # Check if all pods are ready
    local ready_pods=$(kubectl get pods -n $ARGOCD_NAMESPACE --no-headers | grep "1/1" | wc -l)
    local total_pods=$(kubectl get pods -n $ARGOCD_NAMESPACE --no-headers | wc -l)
    
    if [ "$ready_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
        log_success "All ArgoCD pods are ready ($ready_pods/$total_pods)"
        return 0
    else
        log_warning "ArgoCD pods not ready ($ready_pods/$total_pods)"
        return 1
    fi
}

# Show ArgoCD status
show_status() {
    log_header "ArgoCD Status"
    
    echo -e "${BLUE}=== Pods ===${NC}"
    kubectl get pods -n $ARGOCD_NAMESPACE
    
    echo -e "\n${BLUE}=== Services ===${NC}"
    kubectl get svc -n $ARGOCD_NAMESPACE
    
    echo -e "\n${BLUE}=== Applications ===${NC}"
    kubectl get applications -n $ARGOCD_NAMESPACE 2>/dev/null || echo "No applications found"
    
    echo -e "\n${BLUE}=== Access Information ===${NC}"
    echo "Web UI: $NODEPORT_URL"
    echo "Username: admin"
    echo "Password: $ADMIN_PASSWORD"
}

# Install ArgoCD CLI
install_cli() {
    log_info "Installing ArgoCD CLI..."
    
    if command -v argocd >/dev/null 2>&1; then
        log_success "ArgoCD CLI already installed"
        argocd version --client
        return 0
    fi
    
    log_info "Downloading ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    
    log_info "Installing ArgoCD CLI..."
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
    
    log_success "ArgoCD CLI installed successfully"
    argocd version --client
}

# Login to ArgoCD
login_argocd() {
    log_info "Logging into ArgoCD..."
    
    if ! command -v argocd >/dev/null 2>&1; then
        log_warning "ArgoCD CLI not found, installing..."
        install_cli
    fi
    
    # Wait for ArgoCD to be ready
    if ! check_argocd_status; then
        log_error "ArgoCD is not ready"
        return 1
    fi
    
    log_info "Logging in via CLI..."
    if argocd login localhost:30080 --username admin --password "$ADMIN_PASSWORD" --insecure; then
        log_success "Successfully logged into ArgoCD"
    else
        log_error "Failed to login to ArgoCD"
        return 1
    fi
}

# Deploy YouTube Clone application
deploy_app() {
    log_header "Deploying YouTube Clone Application"
    
    # Ensure we're logged in
    if ! login_argocd; then
        return 1
    fi
    
    log_info "Applying ArgoCD application manifest..."
    if kubectl apply -f argocd-application.yaml; then
        log_success "Application manifest applied"
    else
        log_error "Failed to apply application manifest"
        return 1
    fi
    
    log_info "Waiting for application to be created..."
    sleep 5
    
    log_info "Syncing application..."
    if argocd app sync $APP_NAME; then
        log_success "Application synced successfully"
    else
        log_warning "Application sync may have issues, checking status..."
    fi
    
    log_info "Application status:"
    argocd app get $APP_NAME
}

# Show application status
show_app_status() {
    log_header "Application Status"
    
    if ! command -v argocd >/dev/null 2>&1; then
        log_warning "ArgoCD CLI not found, showing kubectl output..."
        kubectl get applications -n $ARGOCD_NAMESPACE
        return 0
    fi
    
    if argocd app list | grep -q $APP_NAME; then
        echo -e "${BLUE}=== ArgoCD Application ===${NC}"
        argocd app get $APP_NAME
        
        echo -e "\n${BLUE}=== Application Resources ===${NC}"
        kubectl get all -n $APP_NAMESPACE
    else
        log_warning "Application $APP_NAME not found in ArgoCD"
        kubectl get applications -n $ARGOCD_NAMESPACE
    fi
}

# Sync application
sync_app() {
    log_info "Syncing application $APP_NAME..."
    
    if ! login_argocd; then
        return 1
    fi
    
    if argocd app sync $APP_NAME; then
        log_success "Application synced successfully"
        argocd app get $APP_NAME
    else
        log_error "Failed to sync application"
        return 1
    fi
}

# Delete application
delete_app() {
    log_warning "Deleting application $APP_NAME..."
    read -p "Are you sure you want to delete the application? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v argocd >/dev/null 2>&1 && argocd app list | grep -q $APP_NAME; then
            argocd app delete $APP_NAME --cascade
        else
            kubectl delete -f argocd-application.yaml 2>/dev/null || true
        fi
        log_success "Application deleted"
    else
        log_info "Operation cancelled"
    fi
}

# Open ArgoCD UI
open_ui() {
    log_info "Opening ArgoCD UI..."
    echo "URL: $NODEPORT_URL"
    echo "Username: admin"
    echo "Password: $ADMIN_PASSWORD"
    
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$NODEPORT_URL"
    elif command -v open >/dev/null 2>&1; then
        open "$NODEPORT_URL"
    else
        log_info "Please open $NODEPORT_URL in your browser"
    fi
}

# Show logs
show_logs() {
    local component=${1:-server}
    
    log_info "Showing ArgoCD $component logs..."
    
    case $component in
        "server")
            kubectl logs -f deployment/argocd-server -n $ARGOCD_NAMESPACE
            ;;
        "controller")
            kubectl logs -f statefulset/argocd-application-controller -n $ARGOCD_NAMESPACE
            ;;
        "repo")
            kubectl logs -f deployment/argocd-repo-server -n $ARGOCD_NAMESPACE
            ;;
        "app")
            if command -v argocd >/dev/null 2>&1; then
                argocd app logs $APP_NAME --follow
            else
                log_error "ArgoCD CLI not available"
            fi
            ;;
        *)
            log_error "Unknown component: $component"
            echo "Available components: server, controller, repo, app"
            ;;
    esac
}

# Main function
main() {
    case "${1:-status}" in
        "status")
            show_status
            ;;
        "install-cli")
            install_cli
            ;;
        "login")
            login_argocd
            ;;
        "deploy")
            deploy_app
            ;;
        "app-status")
            show_app_status
            ;;
        "sync")
            sync_app
            ;;
        "delete")
            delete_app
            ;;
        "ui")
            open_ui
            ;;
        "logs")
            show_logs "${2:-server}"
            ;;
        "help")
            echo "ArgoCD Manager - YouTube Clone V1"
            echo ""
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  status      - Show ArgoCD status (default)"
            echo "  install-cli - Install ArgoCD CLI"
            echo "  login       - Login to ArgoCD CLI"
            echo "  deploy      - Deploy YouTube Clone application"
            echo "  app-status  - Show application status"
            echo "  sync        - Sync application"
            echo "  delete      - Delete application"
            echo "  ui          - Open ArgoCD UI in browser"
            echo "  logs        - Show logs [server|controller|repo|app]"
            echo "  help        - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 status"
            echo "  $0 deploy"
            echo "  $0 logs server"
            echo "  $0 ui"
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
