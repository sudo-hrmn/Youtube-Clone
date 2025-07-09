# Kind Cluster Setup - YouTube Clone V1

## 🎯 **Cluster Overview**

**Cluster Name**: `youtube-clone-v1`  
**Namespace**: `youtube-clone-v1`  
**Environment**: Development/Testing  
**Status**: ✅ **OPERATIONAL**

---

## 🏗️ **Architecture**

### **Cluster Configuration**
- **Type**: Kind (Kubernetes in Docker)
- **Nodes**: 1 Control Plane Node
- **Kubernetes Version**: v1.28.0
- **CNI**: Kindnet (default)
- **Ingress Support**: Enabled with port mappings

### **Network Configuration**
- **Pod Subnet**: 10.244.0.0/16
- **Service Subnet**: 10.96.0.0/16
- **Host Port Mappings**:
  - HTTP: 80 → 80
  - HTTPS: 443 → 443
  - NodePort: 30000-30002 → 30000-30002

---

## 🚀 **Quick Start Commands**

### **Cluster Management**
```bash
# Check cluster status
kubectl cluster-info --context kind-youtube-clone-v1

# Get cluster nodes
kubectl get nodes --context kind-youtube-clone-v1

# Switch to Kind cluster context
kubectl config use-context kind-youtube-clone-v1

# Check namespaces
kubectl get namespaces
```

### **Application Deployment**
```bash
# Deploy YouTube Clone application
kubectl apply -f k8s-deployment.yaml

# Check deployment status
kubectl get all -n youtube-clone-v1

# View pods
kubectl get pods -n youtube-clone-v1 -o wide

# Check services
kubectl get services -n youtube-clone-v1
```

---

## 📊 **Cluster Status**

### **Current Context**
```bash
$ kubectl config current-context
kind-youtube-clone-v1
```

### **Cluster Information**
```bash
$ kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:37977
CoreDNS is running at https://127.0.0.1:37977/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### **Node Status**
```bash
$ kubectl get nodes
NAME                             STATUS   ROLES           AGE   VERSION
youtube-clone-v1-control-plane   Ready    control-plane   5m    v1.28.0
```

### **Namespace Status**
```bash
$ kubectl get namespace youtube-clone-v1
NAME               STATUS   AGE
youtube-clone-v1   Active   3m
```

---

## 🛠️ **Deployment Components**

### **Application Resources**
- **Deployment**: `youtube-clone-deployment` (3 replicas)
- **Service**: `youtube-clone-service` (ClusterIP)
- **NodePort**: `youtube-clone-nodeport` (Port 30000)
- **ConfigMap**: `youtube-clone-config`
- **Secret**: `youtube-clone-secrets`
- **HPA**: `youtube-clone-hpa` (2-10 replicas)
- **Ingress**: `youtube-clone-ingress`

### **Resource Specifications**
```yaml
Resources:
  Requests:
    Memory: 128Mi
    CPU: 100m
  Limits:
    Memory: 512Mi
    CPU: 500m

Scaling:
  Min Replicas: 2
  Max Replicas: 10
  CPU Target: 70%
  Memory Target: 80%
```

---

## 🔧 **Management Commands**

### **Deployment Management**
```bash
# Scale deployment
kubectl scale deployment youtube-clone-deployment --replicas=5 -n youtube-clone-v1

# Update deployment
kubectl set image deployment/youtube-clone-deployment youtube-clone=youtube-clone:v2 -n youtube-clone-v1

# Rollback deployment
kubectl rollout undo deployment/youtube-clone-deployment -n youtube-clone-v1

# Check rollout status
kubectl rollout status deployment/youtube-clone-deployment -n youtube-clone-v1
```

### **Monitoring Commands**
```bash
# View logs
kubectl logs -f deployment/youtube-clone-deployment -n youtube-clone-v1

# Describe pods
kubectl describe pods -n youtube-clone-v1

# Check events
kubectl get events -n youtube-clone-v1 --sort-by='.lastTimestamp'

# Resource usage
kubectl top pods -n youtube-clone-v1
kubectl top nodes
```

### **Debugging Commands**
```bash
# Execute into pod
kubectl exec -it <pod-name> -n youtube-clone-v1 -- /bin/sh

# Port forward for local access
kubectl port-forward service/youtube-clone-service 8080:80 -n youtube-clone-v1

# Check service endpoints
kubectl get endpoints -n youtube-clone-v1
```

---

## 🌐 **Access Methods**

### **1. NodePort Access**
```bash
# Access via NodePort (localhost:30000)
curl http://localhost:30000
```

### **2. Port Forward Access**
```bash
# Port forward to local machine
kubectl port-forward service/youtube-clone-service 8080:80 -n youtube-clone-v1

# Access via localhost:8080
curl http://localhost:8080
```

### **3. Ingress Access** (requires ingress controller)
```bash
# Add to /etc/hosts
echo "127.0.0.1 youtube-clone.local" >> /etc/hosts

# Access via domain
curl http://youtube-clone.local
```

---

## 🔒 **Security Features**

### **Pod Security**
- Non-root user execution (UID: 1000)
- Read-only root filesystem
- No privilege escalation
- Dropped all capabilities
- Security context enforced

### **Network Security**
- ClusterIP service for internal communication
- Ingress with SSL redirect disabled for development
- Network policies can be added for production

---

## 📈 **Monitoring & Observability**

### **Health Checks**
- **Liveness Probe**: HTTP GET / every 10s
- **Readiness Probe**: HTTP GET / every 5s
- **Startup Delay**: 30s for liveness, 5s for readiness

### **Metrics Collection**
- Prometheus annotations enabled
- Metrics endpoint: `/metrics`
- Port: 80

### **Autoscaling**
- CPU-based scaling (70% threshold)
- Memory-based scaling (80% threshold)
- Min: 2 replicas, Max: 10 replicas

---

## 🛡️ **Backup & Recovery**

### **Cluster Backup**
```bash
# Export cluster configuration
kubectl get all -n youtube-clone-v1 -o yaml > youtube-clone-backup.yaml

# Backup persistent data (if any)
kubectl get pv,pvc -n youtube-clone-v1 -o yaml > youtube-clone-storage-backup.yaml
```

### **Disaster Recovery**
```bash
# Recreate cluster
kind delete cluster --name youtube-clone-v1
kind create cluster --config=kind-cluster-simple.yaml

# Restore application
kubectl apply -f youtube-clone-backup.yaml
```

---

## 🔄 **CI/CD Integration**

### **GitHub Actions Integration**
The cluster can be integrated with GitHub Actions for automated deployments:

```yaml
- name: Deploy to Kind
  run: |
    kubectl config use-context kind-youtube-clone-v1
    kubectl apply -f k8s-deployment.yaml
    kubectl rollout status deployment/youtube-clone-deployment -n youtube-clone-v1
```

### **Image Building**
```bash
# Build Docker image for Kind
docker build -t youtube-clone:latest .

# Load image into Kind cluster
kind load docker-image youtube-clone:latest --name youtube-clone-v1
```

---

## 📝 **Next Steps**

1. **Install Ingress Controller** (for ingress access)
2. **Set up Monitoring** (Prometheus/Grafana)
3. **Configure Logging** (ELK stack or similar)
4. **Add Network Policies** (for production security)
5. **Implement GitOps** (ArgoCD or Flux)

---

## 🎯 **Production Readiness**

This Kind cluster setup provides:
- ✅ **High Availability** (multiple replicas)
- ✅ **Auto-scaling** (HPA configured)
- ✅ **Health Monitoring** (probes configured)
- ✅ **Security Hardening** (security contexts)
- ✅ **Resource Management** (requests/limits)
- ✅ **Rolling Updates** (zero-downtime deployments)

**Status**: Ready for development and testing workloads

---

**Created by**: Senior DevOps Engineer  
**Date**: July 9, 2025  
**Version**: 1.0
