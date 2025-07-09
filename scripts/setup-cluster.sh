#!/bin/bash

# Kubernetes Cluster Setup Script for YouTube Clone
# This script sets up the necessary components for the YouTube Clone application

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up Kubernetes cluster for YouTube Clone${NC}"

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install necessary tools
install_tools() {
  echo -e "${BLUE}📦 Installing necessary tools...${NC}"
  
  # Install kubectl if not present
  if ! command_exists kubectl; then
    echo -e "${YELLOW}Installing kubectl...${NC}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
  fi
  
  # Install kustomize if not present
  if ! command_exists kustomize; then
    echo -e "${YELLOW}Installing kustomize...${NC}"
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
  fi
  
  # Install helm if not present
  if ! command_exists helm; then
    echo -e "${YELLOW}Installing helm...${NC}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  fi
  
  echo -e "${GREEN}✅ Tools installed successfully${NC}"
}

# Create namespaces
create_namespaces() {
  echo -e "${BLUE}🏗️ Creating namespaces...${NC}"
  
  namespaces=("youtube-clone-dev" "youtube-clone-staging" "youtube-clone-prod")
  
  for ns in "${namespaces[@]}"; do
    if ! kubectl get namespace "$ns" &> /dev/null; then
      kubectl create namespace "$ns"
      kubectl label namespace "$ns" app=youtube-clone
      echo -e "${GREEN}✅ Created namespace: $ns${NC}"
    else
      echo -e "${YELLOW}⚠️ Namespace already exists: $ns${NC}"
    fi
  done
}

# Install NGINX Ingress Controller
install_nginx_ingress() {
  echo -e "${BLUE}🌐 Installing NGINX Ingress Controller...${NC}"
  
  if ! kubectl get namespace ingress-nginx &> /dev/null; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    
    echo -e "${YELLOW}⏳ Waiting for NGINX Ingress Controller to be ready...${NC}"
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=300s
    
    echo -e "${GREEN}✅ NGINX Ingress Controller installed${NC}"
  else
    echo -e "${YELLOW}⚠️ NGINX Ingress Controller already installed${NC}"
  fi
}

# Install cert-manager for SSL certificates
install_cert_manager() {
  echo -e "${BLUE}🔒 Installing cert-manager...${NC}"
  
  if ! kubectl get namespace cert-manager &> /dev/null; then
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
    
    echo -e "${YELLOW}⏳ Waiting for cert-manager to be ready...${NC}"
    kubectl wait --namespace cert-manager \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/instance=cert-manager \
      --timeout=300s
    
    echo -e "${GREEN}✅ cert-manager installed${NC}"
  else
    echo -e "${YELLOW}⚠️ cert-manager already installed${NC}"
  fi
}

# Create ClusterIssuer for Let's Encrypt
create_cluster_issuer() {
  echo -e "${BLUE}📜 Creating ClusterIssuer for Let's Encrypt...${NC}"
  
  cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # Replace with your email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # Replace with your email
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
  
  echo -e "${GREEN}✅ ClusterIssuer created${NC}"
}

# Install metrics-server for HPA
install_metrics_server() {
  echo -e "${BLUE}📊 Installing metrics-server...${NC}"
  
  if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    echo -e "${YELLOW}⏳ Waiting for metrics-server to be ready...${NC}"
    kubectl wait --namespace kube-system \
      --for=condition=ready pod \
      --selector=k8s-app=metrics-server \
      --timeout=300s
    
    echo -e "${GREEN}✅ metrics-server installed${NC}"
  else
    echo -e "${YELLOW}⚠️ metrics-server already installed${NC}"
  fi
}

# Install Prometheus and Grafana (optional)
install_monitoring() {
  echo -e "${BLUE}📈 Installing monitoring stack (Prometheus & Grafana)...${NC}"
  
  # Add Prometheus Helm repository
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  
  # Install kube-prometheus-stack
  if ! helm list -n monitoring | grep -q kube-prometheus-stack; then
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
      --namespace monitoring \
      --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
      --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
      --set grafana.adminPassword=admin123 \
      --wait
    
    echo -e "${GREEN}✅ Monitoring stack installed${NC}"
    echo -e "${YELLOW}📊 Grafana admin password: admin123${NC}"
  else
    echo -e "${YELLOW}⚠️ Monitoring stack already installed${NC}"
  fi
}

# Create ServiceMonitor for application monitoring
create_service_monitor() {
  echo -e "${BLUE}🔍 Creating ServiceMonitor for YouTube Clone...${NC}"
  
  cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: youtube-clone-monitor
  namespace: monitoring
  labels:
    app: youtube-clone
spec:
  selector:
    matchLabels:
      app: youtube-clone
  namespaceSelector:
    matchNames:
    - youtube-clone-dev
    - youtube-clone-staging
    - youtube-clone-prod
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
EOF
  
  echo -e "${GREEN}✅ ServiceMonitor created${NC}"
}

# Main execution
main() {
  echo -e "${BLUE}🎬 YouTube Clone Kubernetes Setup${NC}"
  echo ""
  
  # Check if kubectl is configured
  if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ kubectl is not configured or cluster is not accessible${NC}"
    echo "Please configure kubectl to connect to your cluster first."
    exit 1
  fi
  
  echo -e "${GREEN}✅ Connected to Kubernetes cluster${NC}"
  kubectl cluster-info
  echo ""
  
  # Install tools
  install_tools
  
  # Create namespaces
  create_namespaces
  
  # Install NGINX Ingress Controller
  install_nginx_ingress
  
  # Install cert-manager
  install_cert_manager
  
  # Create ClusterIssuer
  create_cluster_issuer
  
  # Install metrics-server
  install_metrics_server
  
  # Install monitoring (optional)
  read -p "Do you want to install monitoring stack (Prometheus & Grafana)? [y/N]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_monitoring
    create_service_monitor
  fi
  
  echo ""
  echo -e "${GREEN}🎉 Kubernetes cluster setup completed successfully!${NC}"
  echo ""
  echo -e "${BLUE}📋 Next steps:${NC}"
  echo "1. Update the domain names in the ingress files"
  echo "2. Update the email address in the ClusterIssuer"
  echo "3. Deploy the application using: ./scripts/deploy.sh [environment]"
  echo ""
  echo -e "${BLUE}🔗 Useful commands:${NC}"
  echo "• Check ingress controller: kubectl get pods -n ingress-nginx"
  echo "• Check cert-manager: kubectl get pods -n cert-manager"
  echo "• Check metrics-server: kubectl get pods -n kube-system | grep metrics-server"
  echo "• Access Grafana: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
}

# Run main function
main "$@"
