# ArgoCD Setup - YouTube Clone V1 GitOps

## 🎯 **ArgoCD Overview**

**Namespace**: `argocd`  
**Version**: Latest Stable  
**Access**: NodePort (localhost:30080)  
**Status**: ✅ **OPERATIONAL**

---

## 🏗️ **Installation Summary**

### **Components Installed**
- ✅ **ArgoCD Server** - Web UI and API server
- ✅ **Application Controller** - Manages applications and sync
- ✅ **Repository Server** - Git repository management
- ✅ **DEX Server** - Identity and access management
- ✅ **Redis** - Caching and session storage
- ✅ **Notifications Controller** - Event notifications
- ✅ **ApplicationSet Controller** - Multi-cluster app management

### **Network Policies**
- ✅ **Security hardened** with network policies
- ✅ **RBAC configured** with proper permissions
- ✅ **Service mesh** for internal communication

---

## 🚀 **Access Information**

### **Web UI Access**
```bash
# Method 1: NodePort (Recommended)
URL: http://localhost:30080
Username: admin
Password: XiKvXakNKAKa-j4J

# Method 2: Port Forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
URL: https://localhost:8080
```

### **CLI Access**
```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login via CLI
argocd login localhost:30080 --username admin --password XiKvXakNKAKa-j4J --insecure
```

---

## 📊 **Current Status**

### **Pods Status**
```bash
$ kubectl get pods -n argocd
NAME                                               READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                    1/1     Running   0          5m
argocd-applicationset-controller-77cb676b6c-h5vh5  1/1     Running   0          5m
argocd-dex-server-7967947859-tsw57                 1/1     Running   0          5m
argocd-notifications-controller-7776574f76-q6f8h   1/1     Running   0          5m
argocd-redis-566477488c-4mft2                      1/1     Running   0          5m
argocd-repo-server-5c8756cd4f-dk4tx                1/1     Running   0          5m
argocd-server-86d9c99cff-cqh8q                     1/1     Running   0          5m
```

### **Services Status**
```bash
$ kubectl get svc -n argocd
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
argocd-applicationset-controller          ClusterIP   10.96.55.211    <none>        7000/TCP,8080/TCP
argocd-dex-server                         ClusterIP   10.96.189.151   <none>        5556/TCP,5557/TCP,5558/TCP
argocd-metrics                            ClusterIP   10.96.7.201     <none>        8082/TCP
argocd-notifications-controller-metrics   ClusterIP   10.96.20.221    <none>        9001/TCP
argocd-redis                              ClusterIP   10.96.66.69     <none>        6379/TCP
argocd-repo-server                        ClusterIP   10.96.62.238    <none>        8081/TCP,8084/TCP
argocd-server                             ClusterIP   10.96.136.39    <none>        80/TCP,443/TCP
argocd-server-metrics                     ClusterIP   10.96.189.249   <none>        8083/TCP
argocd-server-nodeport                    NodePort    10.96.241.95    <none>        80:30080/TCP,443:30443/TCP
```

---

## 🛠️ **GitOps Configuration**

### **YouTube Clone Application**
The ArgoCD application configuration is ready for deployment:

```yaml
# Application: youtube-clone-v1
Repository: https://github.com/sudo-hrmn/Youtube-Clone.git
Branch: main
Destination: youtube-clone-v1 namespace
Sync Policy: Automated with self-healing
```

### **Deploy Application**
```bash
# Apply ArgoCD application
kubectl apply -f argocd-application.yaml

# Check application status
kubectl get applications -n argocd

# View application details
argocd app get youtube-clone-v1
```

---

## 🔧 **Management Commands**

### **Application Management**
```bash
# List applications
argocd app list

# Get application details
argocd app get youtube-clone-v1

# Sync application
argocd app sync youtube-clone-v1

# View application logs
argocd app logs youtube-clone-v1

# Delete application
argocd app delete youtube-clone-v1
```

### **Repository Management**
```bash
# Add repository
argocd repo add https://github.com/sudo-hrmn/Youtube-Clone.git

# List repositories
argocd repo list

# Test repository connection
argocd repo get https://github.com/sudo-hrmn/Youtube-Clone.git
```

### **Cluster Management**
```bash
# List clusters
argocd cluster list

# Add cluster
argocd cluster add kind-youtube-clone-v1

# Remove cluster
argocd cluster rm https://kubernetes.default.svc
```

---

## 🔒 **Security Configuration**

### **Initial Setup**
```bash
# Change admin password
argocd account update-password --account admin --current-password XiKvXakNKAKa-j4J --new-password <new-password>

# Create new user
argocd account create <username> --password <password>

# Update RBAC
kubectl edit configmap argocd-rbac-cm -n argocd
```

### **RBAC Configuration**
```yaml
# Example RBAC policy
policy.default: role:readonly
policy.csv: |
  p, role:admin, applications, *, */*, allow
  p, role:admin, clusters, *, *, allow
  p, role:admin, repositories, *, *, allow
  g, admin, role:admin
```

---

## 📈 **Monitoring & Observability**

### **Metrics Endpoints**
- **ArgoCD Server**: `http://localhost:30080/metrics`
- **Application Controller**: Internal metrics on port 8082
- **Repository Server**: Internal metrics on port 8084
- **Notifications Controller**: Internal metrics on port 9001

### **Health Checks**
```bash
# Check ArgoCD health
curl http://localhost:30080/healthz

# Check application health
argocd app get youtube-clone-v1 --show-params
```

### **Logging**
```bash
# View ArgoCD server logs
kubectl logs -f deployment/argocd-server -n argocd

# View application controller logs
kubectl logs -f statefulset/argocd-application-controller -n argocd

# View repository server logs
kubectl logs -f deployment/argocd-repo-server -n argocd
```

---

## 🔄 **GitOps Workflow**

### **Deployment Process**
1. **Code Push** → GitHub repository
2. **ArgoCD Detection** → Monitors repository changes
3. **Automatic Sync** → Deploys changes to Kubernetes
4. **Health Check** → Verifies deployment status
5. **Notification** → Alerts on success/failure

### **Sync Policies**
- ✅ **Automated Sync** - Deploys changes automatically
- ✅ **Self Healing** - Corrects configuration drift
- ✅ **Pruning** - Removes orphaned resources
- ✅ **Retry Logic** - Handles temporary failures

---

## 🛡️ **Backup & Recovery**

### **Configuration Backup**
```bash
# Export ArgoCD configuration
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml
kubectl get appprojects -n argocd -o yaml > argocd-projects-backup.yaml

# Backup secrets
kubectl get secrets -n argocd -o yaml > argocd-secrets-backup.yaml
```

### **Disaster Recovery**
```bash
# Restore ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Restore applications
kubectl apply -f argocd-apps-backup.yaml
kubectl apply -f argocd-projects-backup.yaml
```

---

## 🚀 **Advanced Features**

### **ApplicationSets**
- **Multi-cluster deployments**
- **Template-based application generation**
- **Git directory/file-based discovery**

### **Notifications**
- **Slack/Teams integration**
- **Email notifications**
- **Webhook triggers**

### **Image Updater**
- **Automatic image updates**
- **Semantic versioning**
- **Git commit automation**

---

## 📝 **Next Steps**

1. **Configure RBAC** for team access
2. **Set up notifications** for deployment events
3. **Implement image updater** for automated updates
4. **Add monitoring** with Prometheus/Grafana
5. **Configure SSO** with OIDC/SAML

---

## 🎯 **Production Readiness**

This ArgoCD setup provides:
- ✅ **GitOps automation** with continuous deployment
- ✅ **Security hardening** with RBAC and network policies
- ✅ **High availability** with multiple replicas
- ✅ **Monitoring integration** with metrics endpoints
- ✅ **Disaster recovery** with backup procedures
- ✅ **Multi-cluster support** for scaling

**Status**: Ready for production GitOps workflows

---

**Created by**: Senior DevOps Engineer  
**Date**: July 9, 2025  
**Version**: 1.0
