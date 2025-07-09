#!/bin/bash

# ArgoCD Access Script - Multiple Access Methods
# Professional ArgoCD UI access with troubleshooting

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
    
    local ready_pods=$(kubectl get pods -n $ARGOCD_NAMESPACE --no-headers 2>/dev/null | grep "1/1" | wc -l)
    local total_pods=$(kubectl get pods -n $ARGOCD_NAMESPACE --no-headers 2>/dev/null | wc -l)
    
    if [ "$ready_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
        log_success "ArgoCD is running ($ready_pods/$total_pods pods ready)"
        return 0
    else
        log_error "ArgoCD is not ready ($ready_pods/$total_pods pods ready)"
        return 1
    fi
}

# Method 1: Port Forward (Most Reliable)
setup_port_forward() {
    log_header "Method 1: Port Forward Access"
    
    # Kill existing port-forward processes
    pkill -f "kubectl port-forward.*argocd-server" 2>/dev/null || true
    sleep 2
    
    log_info "Setting up port forwarding..."
    kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 --address=0.0.0.0 > /tmp/argocd-port-forward.log 2>&1 &
    
    # Wait for port forward to be ready
    sleep 5
    
    if pgrep -f "kubectl port-forward.*argocd-server" > /dev/null; then
        log_success "Port forwarding active"
        echo -e "${GREEN}✅ ArgoCD UI Access:${NC}"
        echo "   URL: https://localhost:8080"
        echo "   Username: admin"
        echo "   Password: $ADMIN_PASSWORD"
        echo "   Note: Accept the self-signed certificate warning"
        echo ""
        echo -e "${YELLOW}💡 To stop port forwarding later:${NC}"
        echo "   pkill -f 'kubectl port-forward.*argocd-server'"
        return 0
    else
        log_error "Port forwarding failed"
        cat /tmp/argocd-port-forward.log 2>/dev/null || true
        return 1
    fi
}

# Method 2: NodePort (Fixed for Kind)
setup_nodeport() {
    log_header "Method 2: NodePort Access"
    
    log_info "Checking NodePort service..."
    if kubectl get svc argocd-server-nodeport -n $ARGOCD_NAMESPACE >/dev/null 2>&1; then
        local nodeport=$(kubectl get svc argocd-server-nodeport -n $ARGOCD_NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
        log_success "NodePort service found (port: $nodeport)"
        
        echo -e "${GREEN}✅ ArgoCD UI Access:${NC}"
        echo "   URL: http://localhost:$nodeport"
        echo "   Username: admin"
        echo "   Password: $ADMIN_PASSWORD"
        
        # Test connection
        log_info "Testing connection..."
        if timeout 5 curl -s -o /dev/null -w "%{http_code}" http://localhost:$nodeport | grep -q "200\|302\|401"; then
            log_success "NodePort access working"
            return 0
        else
            log_warning "NodePort may not be accessible (Kind cluster port mapping issue)"
            return 1
        fi
    else
        log_error "NodePort service not found"
        return 1
    fi
}

# Method 3: Direct Pod Access
setup_pod_access() {
    log_header "Method 3: Direct Pod Access"
    
    local pod_name=$(kubectl get pods -n $ARGOCD_NAMESPACE -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}')
    
    if [ -n "$pod_name" ]; then
        log_info "Setting up direct pod port forwarding..."
        pkill -f "kubectl port-forward.*$pod_name" 2>/dev/null || true
        sleep 2
        
        kubectl port-forward pod/$pod_name -n $ARGOCD_NAMESPACE 8081:8080 --address=0.0.0.0 > /tmp/argocd-pod-forward.log 2>&1 &
        sleep 5
        
        if pgrep -f "kubectl port-forward.*$pod_name" > /dev/null; then
            log_success "Direct pod access active"
            echo -e "${GREEN}✅ ArgoCD UI Access:${NC}"
            echo "   URL: http://localhost:8081"
            echo "   Username: admin"
            echo "   Password: $ADMIN_PASSWORD"
            return 0
        else
            log_error "Direct pod access failed"
            return 1
        fi
    else
        log_error "ArgoCD server pod not found"
        return 1
    fi
}

# Show all access methods
show_access_methods() {
    log_header "ArgoCD Access Methods"
    
    echo -e "${BLUE}Available access methods:${NC}"
    echo ""
    echo -e "${GREEN}1. Port Forward (Recommended):${NC}"
    echo "   URL: https://localhost:8080"
    echo "   Command: ./argocd-access.sh port-forward"
    echo ""
    echo -e "${GREEN}2. NodePort:${NC}"
    echo "   URL: http://localhost:30001"
    echo "   Command: ./argocd-access.sh nodeport"
    echo ""
    echo -e "${GREEN}3. Direct Pod Access:${NC}"
    echo "   URL: http://localhost:8081"
    echo "   Command: ./argocd-access.sh pod"
    echo ""
    echo -e "${YELLOW}Login Credentials:${NC}"
    echo "   Username: admin"
    echo "   Password: $ADMIN_PASSWORD"
}

# Troubleshoot access issues
troubleshoot() {
    log_header "ArgoCD Access Troubleshooting"
    
    echo -e "${BLUE}=== ArgoCD Status ===${NC}"
    kubectl get pods -n $ARGOCD_NAMESPACE
    
    echo -e "\n${BLUE}=== Services ===${NC}"
    kubectl get svc -n $ARGOCD_NAMESPACE
    
    echo -e "\n${BLUE}=== Kind Cluster Ports ===${NC}"
    docker ps | grep youtube-clone-v1-control-plane | grep -o "0.0.0.0:[0-9]*->[0-9]*" || echo "No port mappings found"
    
    echo -e "\n${BLUE}=== Active Port Forwards ===${NC}"
    ps aux | grep "kubectl port-forward" | grep -v grep || echo "No active port forwards"
    
    echo -e "\n${BLUE}=== Network Connectivity ===${NC}"
    log_info "Testing localhost connectivity..."
    
    # Test different ports
    for port in 8080 8081 30001 30002; do
        if timeout 2 curl -s -o /dev/null -w "%{http_code}" http://localhost:$port 2>/dev/null | grep -q "200\|302\|401\|404"; then
            echo "✅ Port $port: Accessible"
        else
            echo "❌ Port $port: Not accessible"
        fi
    done
    
    echo -e "\n${YELLOW}=== Recommended Solutions ===${NC}"
    echo "1. Use port forwarding: ./argocd-access.sh port-forward"
    echo "2. Check firewall settings"
    echo "3. Restart Kind cluster if needed"
    echo "4. Use alternative access methods"
}

# Stop all port forwards
stop_port_forwards() {
    log_info "Stopping all ArgoCD port forwards..."
    pkill -f "kubectl port-forward.*argocd" 2>/dev/null || true
    log_success "Port forwards stopped"
}

# Auto setup (tries all methods)
auto_setup() {
    log_header "Auto Setup - Finding Best Access Method"
    
    if ! check_argocd_status; then
        log_error "ArgoCD is not ready. Please check the installation."
        return 1
    fi
    
    log_info "Trying port forward method..."
    if setup_port_forward; then
        return 0
    fi
    
    log_info "Trying NodePort method..."
    if setup_nodeport; then
        return 0
    fi
    
    log_info "Trying direct pod access..."
    if setup_pod_access; then
        return 0
    fi
    
    log_error "All access methods failed. Running troubleshooting..."
    troubleshoot
    return 1
}

# Main function
main() {
    case "${1:-auto}" in
        "port-forward"|"pf")
            setup_port_forward
            ;;
        "nodeport"|"np")
            setup_nodeport
            ;;
        "pod"|"direct")
            setup_pod_access
            ;;
        "auto"|"setup")
            auto_setup
            ;;
        "status"|"check")
            check_argocd_status
            show_access_methods
            ;;
        "troubleshoot"|"debug")
            troubleshoot
            ;;
        "stop")
            stop_port_forwards
            ;;
        "help")
            echo "ArgoCD Access Script - YouTube Clone V1"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  auto         - Auto setup best access method (default)"
            echo "  port-forward - Setup port forwarding (recommended)"
            echo "  nodeport     - Use NodePort access"
            echo "  pod          - Direct pod access"
            echo "  status       - Check ArgoCD status and show access methods"
            echo "  troubleshoot - Run troubleshooting diagnostics"
            echo "  stop         - Stop all port forwards"
            echo "  help         - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 auto"
            echo "  $0 port-forward"
            echo "  $0 troubleshoot"
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
