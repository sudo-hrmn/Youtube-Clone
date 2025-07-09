#!/bin/bash

# YouTube Clone Deployment Script
# Usage: ./scripts/deploy.sh [environment] [image-tag]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=${1:-development}
IMAGE_TAG=${2:-latest}
NAMESPACE="youtube-clone-${ENVIRONMENT}"

# Validate environment
case $ENVIRONMENT in
  development|staging|production)
    echo -e "${GREEN}✓ Valid environment: $ENVIRONMENT${NC}"
    ;;
  *)
    echo -e "${RED}✗ Invalid environment: $ENVIRONMENT${NC}"
    echo "Valid environments: development, staging, production"
    exit 1
    ;;
esac

# Function to check if kubectl is available
check_kubectl() {
  if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl is not installed${NC}"
    exit 1
  fi
  echo -e "${GREEN}✓ kubectl is available${NC}"
}

# Function to check if kustomize is available
check_kustomize() {
  if ! command -v kustomize &> /dev/null; then
    echo -e "${YELLOW}⚠ kustomize not found, using kubectl apply -k${NC}"
  else
    echo -e "${GREEN}✓ kustomize is available${NC}"
  fi
}

# Function to check cluster connectivity
check_cluster() {
  echo -e "${BLUE}🔍 Checking cluster connectivity...${NC}"
  if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
    exit 1
  fi
  echo -e "${GREEN}✓ Connected to cluster${NC}"
}

# Function to create namespace if it doesn't exist
create_namespace() {
  echo -e "${BLUE}🔍 Checking namespace: $NAMESPACE${NC}"
  if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo -e "${YELLOW}⚠ Creating namespace: $NAMESPACE${NC}"
    kubectl create namespace "$NAMESPACE"
    kubectl label namespace "$NAMESPACE" environment="$ENVIRONMENT"
  else
    echo -e "${GREEN}✓ Namespace exists: $NAMESPACE${NC}"
  fi
}

# Function to update image tag
update_image_tag() {
  echo -e "${BLUE}🔄 Updating image tag to: $IMAGE_TAG${NC}"
  cd "kubernetes/overlays/$ENVIRONMENT"
  
  # Update kustomization.yaml with new image tag
  if [[ -f kustomization.yaml ]]; then
    sed -i.bak "s|newTag: .*|newTag: $IMAGE_TAG|g" kustomization.yaml
    echo -e "${GREEN}✓ Updated image tag in kustomization.yaml${NC}"
  fi
}

# Function to deploy application
deploy_app() {
  echo -e "${BLUE}🚀 Deploying to $ENVIRONMENT environment...${NC}"
  
  cd "kubernetes/overlays/$ENVIRONMENT"
  
  # Apply the manifests
  kubectl apply -k . --namespace="$NAMESPACE"
  
  echo -e "${BLUE}⏳ Waiting for deployment to complete...${NC}"
  
  # Wait for deployment to be ready
  if kubectl rollout status deployment/youtube-clone -n "$NAMESPACE" --timeout=300s; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
  else
    echo -e "${RED}❌ Deployment failed or timed out${NC}"
    exit 1
  fi
}

# Function to run health checks
health_check() {
  echo -e "${BLUE}🏥 Running health checks...${NC}"
  
  # Get service endpoint
  SERVICE_IP=$(kubectl get service youtube-clone-service -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  
  if [[ -z "$SERVICE_IP" ]]; then
    echo -e "${YELLOW}⚠ LoadBalancer IP not available, using port-forward for health check${NC}"
    kubectl port-forward service/youtube-clone-service 8080:80 -n "$NAMESPACE" &
    PORT_FORWARD_PID=$!
    sleep 5
    
    if curl -f http://localhost:8080/health &> /dev/null; then
      echo -e "${GREEN}✅ Health check passed${NC}"
    else
      echo -e "${RED}❌ Health check failed${NC}"
    fi
    
    kill $PORT_FORWARD_PID 2>/dev/null || true
  else
    if curl -f "http://$SERVICE_IP/health" &> /dev/null; then
      echo -e "${GREEN}✅ Health check passed${NC}"
    else
      echo -e "${RED}❌ Health check failed${NC}"
    fi
  fi
}

# Function to show deployment info
show_info() {
  echo -e "${BLUE}📊 Deployment Information:${NC}"
  echo "Environment: $ENVIRONMENT"
  echo "Namespace: $NAMESPACE"
  echo "Image Tag: $IMAGE_TAG"
  echo ""
  
  echo -e "${BLUE}📋 Pod Status:${NC}"
  kubectl get pods -n "$NAMESPACE" -l app=youtube-clone
  echo ""
  
  echo -e "${BLUE}🌐 Service Status:${NC}"
  kubectl get services -n "$NAMESPACE"
  echo ""
  
  echo -e "${BLUE}🔗 Ingress Status:${NC}"
  kubectl get ingress -n "$NAMESPACE" 2>/dev/null || echo "No ingress found"
}

# Function to rollback deployment
rollback() {
  echo -e "${YELLOW}🔄 Rolling back deployment...${NC}"
  kubectl rollout undo deployment/youtube-clone -n "$NAMESPACE"
  kubectl rollout status deployment/youtube-clone -n "$NAMESPACE" --timeout=300s
  echo -e "${GREEN}✅ Rollback completed${NC}"
}

# Main execution
main() {
  echo -e "${BLUE}🚀 YouTube Clone Deployment Script${NC}"
  echo "Environment: $ENVIRONMENT"
  echo "Image Tag: $IMAGE_TAG"
  echo ""
  
  # Pre-flight checks
  check_kubectl
  check_kustomize
  check_cluster
  
  # Create namespace
  create_namespace
  
  # Update image tag
  update_image_tag
  
  # Deploy application
  deploy_app
  
  # Run health checks
  health_check
  
  # Show deployment info
  show_info
  
  echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
}

# Handle script arguments
case "${3:-}" in
  --rollback)
    rollback
    exit 0
    ;;
  --info)
    show_info
    exit 0
    ;;
  *)
    main
    ;;
esac
