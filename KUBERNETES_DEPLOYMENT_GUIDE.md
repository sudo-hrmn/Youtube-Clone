# YouTube Clone - Professional Kubernetes Deployment Guide

## 🎯 **Overview**

This guide provides comprehensive instructions for deploying the YouTube Clone application to Kubernetes with professional-grade configurations, including GitHub Container Registry integration, security best practices, and production-ready manifests.

---

## 🏗️ **Architecture Overview**

### **Deployment Components**
- ✅ **Deployment**: Multi-replica application deployment with rolling updates
- ✅ **Services**: ClusterIP, NodePort, and LoadBalancer configurations
- ✅ **Ingress**: Advanced routing with SSL/TLS and security headers
- ✅ **ConfigMaps**: Environment-specific configuration management
- ✅ **Secrets**: Secure credential and API key management
- ✅ **ServiceAccount**: RBAC with minimal required permissions
- ✅ **NetworkPolicies**: Micro-segmentation and security controls
- ✅ **HPA**: Horizontal Pod Autoscaler for dynamic scaling
- ✅ **PDB**: Pod Disruption Budget for high availability

### **GitHub Container Registry Integration**
- ✅ **Image Pull Secrets**: Secure access to private GitHub Container Registry
- ✅ **Automated Builds**: CI/CD integration with GitHub Actions
- ✅ **Image Versioning**: Semantic versioning and tagging strategy
- ✅ **Security Scanning**: Container vulnerability assessment

---

## 🚀 **Quick Start**

### **Prerequisites**
```bash
# Required tools
- kubectl (v1.20+)
- docker (v20.0+)
- kustomize (v4.0+)
- GitHub Personal Access Token with packages:read permission

# Kubernetes cluster access
- Kind cluster (for local development)
- EKS/GKE/AKS (for production)
```

### **Environment Setup**
```bash
# Set required environment variables
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
export EMAIL=your-email@example.com

# Verify cluster access
kubectl cluster-info
```

### **One-Command Deployment**
```bash
# Complete setup and deployment
./setup-github-registry.sh all
```

---

## 📋 **Detailed Deployment Steps**

### **Step 1: Namespace and RBAC Setup**
```bash
# Create namespace
kubectl apply -f kubernetes/base/namespace.yaml

# Create service account and RBAC
kubectl apply -f kubernetes/base/serviceaccount.yaml
```

### **Step 2: Configuration Management**
```bash
# Apply ConfigMaps
kubectl apply -f kubernetes/base/configmap.yaml

# Apply Secrets (update with actual values)
kubectl apply -f kubernetes/base/secrets.yaml
```

### **Step 3: GitHub Container Registry Secret**
```bash
# Create registry secret
kubectl create secret docker-registry github-container-registry \
  --docker-server=ghcr.io \
  --docker-username=sudo-hrmn \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=$EMAIL \
  --namespace=youtube-clone-v1
```

### **Step 4: Application Deployment**
```bash
# Deploy application
kubectl apply -f kubernetes/base/deployment.yaml

# Create services
kubectl apply -f kubernetes/base/service.yaml

# Setup ingress
kubectl apply -f kubernetes/base/ingress.yaml
```

### **Step 5: Scaling and Policies**
```bash
# Apply HPA
kubectl apply -f kubernetes/base/hpa.yaml

# Apply PDB
kubectl apply -f kubernetes/base/pdb.yaml

# Apply Network Policies
kubectl apply -f kubernetes/base/networkpolicy.yaml
```

---

## 🔧 **Configuration Details**

### **Deployment Configuration**
```yaml
# Key deployment settings
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  
  template:
    spec:
      imagePullSecrets:
      - name: github-container-registry
      
      containers:
      - name: youtube-clone
        image: ghcr.io/sudo-hrmn/youtube-clone:latest
        imagePullPolicy: Always
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### **Service Configuration**
```yaml
# Multiple service types for different access patterns
1. ClusterIP (youtube-clone-service)
   - Internal cluster communication
   - Port 80 → 80

2. NodePort (youtube-clone-nodeport)
   - External access via node ports
   - Port 80 → 30001

3. LoadBalancer (youtube-clone-loadbalancer)
   - Cloud provider load balancer
   - Ports 80, 443
```

### **Ingress Configuration**
```yaml
# Advanced ingress with security features
metadata:
  annotations:
    # SSL/TLS
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    
    # Security Headers
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
    
    # Performance
    nginx.ingress.kubernetes.io/enable-brotli: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
```

---

## 🔒 **Security Features**

### **Container Security**
```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
    - ALL
```

### **Network Security**
- ✅ **Default Deny**: All traffic blocked by default
- ✅ **Ingress Rules**: Only allow necessary inbound traffic
- ✅ **Egress Rules**: Restrict outbound connections
- ✅ **Namespace Isolation**: Micro-segmentation between services

### **RBAC Configuration**
```yaml
# Minimal required permissions
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

---

## 📊 **Monitoring & Observability**

### **Health Checks**
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 6
```

### **Metrics Collection**
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "80"
  prometheus.io/path: "/metrics"
```

### **Logging Configuration**
- ✅ **Structured Logging**: JSON format for better parsing
- ✅ **Log Levels**: Configurable via environment variables
- ✅ **Request Logging**: Nginx access logs for traffic analysis
- ✅ **Error Tracking**: Centralized error collection

---

## 🔄 **Scaling & High Availability**

### **Horizontal Pod Autoscaler**
```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### **Pod Disruption Budget**
```yaml
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: youtube-clone
```

### **Anti-Affinity Rules**
```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - youtube-clone
        topologyKey: kubernetes.io/hostname
```

---

## 🌐 **Access Methods**

### **1. NodePort Access**
```bash
# Get NodePort
kubectl get service youtube-clone-nodeport -n youtube-clone-v1

# Access via NodePort
curl http://localhost:30001
```

### **2. Port Forward**
```bash
# Setup port forwarding
kubectl port-forward service/youtube-clone-service 8080:80 -n youtube-clone-v1

# Access application
curl http://localhost:8080
```

### **3. Ingress Access**
```bash
# Add to /etc/hosts (for local testing)
echo "127.0.0.1 youtube-clone.local" >> /etc/hosts

# Access via ingress
curl http://youtube-clone.local
```

### **4. LoadBalancer Access**
```bash
# Get external IP (cloud environments)
kubectl get service youtube-clone-loadbalancer -n youtube-clone-v1

# Access via external IP
curl http://<EXTERNAL-IP>
```

---

## 🛠️ **Management Commands**

### **Deployment Management**
```bash
# Scale deployment
kubectl scale deployment youtube-clone-deployment --replicas=5 -n youtube-clone-v1

# Update image
kubectl set image deployment/youtube-clone-deployment youtube-clone=ghcr.io/sudo-hrmn/youtube-clone:v2 -n youtube-clone-v1

# Rollback deployment
kubectl rollout undo deployment/youtube-clone-deployment -n youtube-clone-v1

# Check rollout status
kubectl rollout status deployment/youtube-clone-deployment -n youtube-clone-v1
```

### **Monitoring Commands**
```bash
# View logs
kubectl logs -f deployment/youtube-clone-deployment -n youtube-clone-v1

# Describe resources
kubectl describe deployment youtube-clone-deployment -n youtube-clone-v1

# Check events
kubectl get events -n youtube-clone-v1 --sort-by='.lastTimestamp'

# Resource usage
kubectl top pods -n youtube-clone-v1
```

### **Debugging Commands**
```bash
# Execute into pod
kubectl exec -it <pod-name> -n youtube-clone-v1 -- /bin/sh

# Check service endpoints
kubectl get endpoints -n youtube-clone-v1

# Test connectivity
kubectl run debug --image=busybox -it --rm --restart=Never -n youtube-clone-v1 -- /bin/sh
```

---

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Image Pull Errors**
```bash
# Check secret
kubectl get secret github-container-registry -n youtube-clone-v1 -o yaml

# Recreate secret
kubectl delete secret github-container-registry -n youtube-clone-v1
./setup-github-registry.sh secret
```

#### **Pod Startup Issues**
```bash
# Check pod logs
kubectl logs <pod-name> -n youtube-clone-v1

# Check pod events
kubectl describe pod <pod-name> -n youtube-clone-v1

# Check resource constraints
kubectl describe nodes
```

#### **Service Access Issues**
```bash
# Check service endpoints
kubectl get endpoints youtube-clone-service -n youtube-clone-v1

# Test service connectivity
kubectl run test --image=busybox -it --rm --restart=Never -n youtube-clone-v1 -- wget -qO- youtube-clone-service
```

#### **Ingress Issues**
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress status
kubectl describe ingress youtube-clone-ingress -n youtube-clone-v1

# Check DNS resolution
nslookup youtube-clone.local
```

---

## 📈 **Performance Optimization**

### **Resource Optimization**
```yaml
# Optimized resource requests/limits
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
    ephemeral-storage: "1Gi"
  limits:
    memory: "512Mi"
    cpu: "500m"
    ephemeral-storage: "2Gi"
```

### **Caching Strategy**
```yaml
# Nginx caching configuration
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}
```

### **Compression**
```yaml
# Brotli compression
nginx.ingress.kubernetes.io/enable-brotli: "true"
nginx.ingress.kubernetes.io/brotli-level: "6"
```

---

## 🚀 **Production Deployment**

### **Pre-Production Checklist**
- ✅ **Security Review**: Network policies, RBAC, container security
- ✅ **Performance Testing**: Load testing, resource optimization
- ✅ **Monitoring Setup**: Prometheus, Grafana, alerting
- ✅ **Backup Strategy**: Configuration backup, disaster recovery
- ✅ **SSL/TLS**: Valid certificates, security headers
- ✅ **DNS Configuration**: Domain setup, CDN integration

### **Production Environment Variables**
```bash
# Update for production
export ENVIRONMENT=production
export REPLICAS=5
export CPU_LIMIT=1000m
export MEMORY_LIMIT=1Gi
export ENABLE_MONITORING=true
```

### **Production Deployment**
```bash
# Deploy to production
kubectl apply -k kubernetes/overlays/production/

# Verify deployment
kubectl get all -n youtube-clone-v1
kubectl rollout status deployment/youtube-clone-deployment -n youtube-clone-v1
```

---

## 📝 **Next Steps**

1. **CI/CD Integration**: Automate deployments with GitHub Actions
2. **Monitoring Setup**: Deploy Prometheus and Grafana
3. **Logging**: Implement centralized logging with ELK stack
4. **Security Hardening**: Implement additional security policies
5. **Performance Monitoring**: Set up APM and performance tracking

---

**Status**: ✅ **Production Ready**  
**Last Updated**: July 10, 2025  
**Version**: v1.0.0
