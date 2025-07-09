# YouTube Clone - Deployment Guide

This guide provides comprehensive instructions for deploying the YouTube Clone application to Kubernetes using modern DevOps practices.

## 🏗️ Architecture Overview

The deployment architecture consists of:

- **Multi-environment setup**: Development, Staging, Production
- **Kubernetes-native**: Using Deployments, Services, Ingress, HPA, PDB
- **GitOps workflow**: Automated deployments via GitHub Actions
- **Security-first**: Non-root containers, security scanning, RBAC
- **Observability**: Monitoring, logging, and health checks
- **Scalability**: Horizontal Pod Autoscaling and load balancing

## 📋 Prerequisites

### Required Tools
- `kubectl` (v1.28+)
- `kustomize` (v5.0+)
- `helm` (v3.12+)
- `docker` (v24.0+)
- Access to a Kubernetes cluster (EKS, GKE, AKS, or local)

### Cluster Requirements
- Kubernetes v1.28+
- NGINX Ingress Controller
- cert-manager (for SSL certificates)
- metrics-server (for HPA)
- At least 2 CPU cores and 4GB RAM available

## 🚀 Quick Start

### 1. Cluster Setup

Run the automated cluster setup script:

```bash
./scripts/setup-cluster.sh
```

This script will install:
- NGINX Ingress Controller
- cert-manager for SSL certificates
- metrics-server for autoscaling
- Monitoring stack (optional)

### 2. Deploy to Development

```bash
./scripts/deploy.sh development latest
```

### 3. Deploy to Staging

```bash
./scripts/deploy.sh staging v1.0.0
```

### 4. Deploy to Production

```bash
./scripts/deploy.sh production v1.0.0
```

## 🏗️ Manual Deployment

### Environment-Specific Deployments

#### Development Environment
```bash
cd kubernetes/overlays/development
kubectl apply -k .
```

#### Staging Environment
```bash
cd kubernetes/overlays/staging
kubectl apply -k .
```

#### Production Environment
```bash
cd kubernetes/overlays/production
kubectl apply -k .
```

## 🔧 Configuration

### Environment Variables

Each environment can be configured with specific variables:

| Variable | Development | Staging | Production |
|----------|-------------|---------|------------|
| `NODE_ENV` | development | staging | production |
| `REPLICAS` | 1 | 2 | 5 |
| `CPU_REQUEST` | 50m | 75m | 200m |
| `MEMORY_REQUEST` | 64Mi | 96Mi | 256Mi |
| `CPU_LIMIT` | 200m | 300m | 1000m |
| `MEMORY_LIMIT` | 256Mi | 384Mi | 1Gi |

### Domain Configuration

Update the following files with your domain names:

1. **Development**: `kubernetes/overlays/development/ingress-patch.yaml`
2. **Staging**: `kubernetes/overlays/staging/ingress-patch.yaml`
3. **Production**: `kubernetes/overlays/production/ingress-patch.yaml`

Replace `yourdomain.com` with your actual domain.

### SSL Certificates

Update the email address in the ClusterIssuer:

```bash
kubectl edit clusterissuer letsencrypt-prod
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The CI/CD pipeline includes:

1. **Security Scanning**: SonarCloud, dependency audit
2. **Testing**: Unit tests, integration tests, coverage
3. **Building**: Multi-platform Docker images
4. **Security**: Container vulnerability scanning
5. **Deployment**: Automated deployment to environments
6. **Monitoring**: Health checks and notifications

### Required Secrets

Configure these secrets in your GitHub repository:

```bash
# GitHub Container Registry
GITHUB_TOKEN

# SonarCloud (optional)
SONAR_TOKEN

# Kubernetes clusters
KUBE_CONFIG_DEV      # Base64 encoded kubeconfig for development
KUBE_CONFIG_STAGING  # Base64 encoded kubeconfig for staging
KUBE_CONFIG_PROD     # Base64 encoded kubeconfig for production

# Notifications (optional)
SLACK_WEBHOOK_URL
```

### Workflow Triggers

- **Push to `develop`**: Deploy to development
- **Push to `staging`**: Deploy to staging
- **Push to `main`**: Deploy to production
- **Pull Requests**: Run tests and security scans

## 📊 Monitoring and Observability

### Health Checks

The application includes comprehensive health checks:

- **Liveness Probe**: `/health` endpoint
- **Readiness Probe**: `/health` endpoint
- **Startup Probe**: Initial health verification

### Metrics and Monitoring

If monitoring is enabled:

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **AlertManager**: Alert notifications

Access Grafana:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Default credentials: `admin` / `admin123`

### Logging

Application logs are available via:

```bash
# View application logs
kubectl logs -f deployment/youtube-clone -n youtube-clone-prod

# View ingress logs
kubectl logs -f -n ingress-nginx deployment/ingress-nginx-controller
```

## 🔒 Security

### Container Security

- **Non-root user**: Containers run as user ID 1001
- **Read-only filesystem**: Root filesystem is read-only
- **Security context**: Dropped capabilities, no privilege escalation
- **Vulnerability scanning**: Trivy scans for CVEs

### Network Security

- **Network policies**: Restrict pod-to-pod communication
- **Ingress security**: Rate limiting, OWASP ModSecurity rules
- **TLS encryption**: Automatic SSL certificates via cert-manager

### RBAC

Kubernetes RBAC is configured for:
- Service accounts with minimal permissions
- Role-based access control
- Namespace isolation

## 📈 Scaling

### Horizontal Pod Autoscaling (HPA)

Automatic scaling based on:
- CPU utilization (60-70% target)
- Memory utilization (70-80% target)
- Custom metrics (optional)

### Manual Scaling

```bash
# Scale deployment
kubectl scale deployment youtube-clone --replicas=10 -n youtube-clone-prod

# Check HPA status
kubectl get hpa -n youtube-clone-prod
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Pod Not Starting
```bash
# Check pod status
kubectl get pods -n youtube-clone-prod

# View pod logs
kubectl logs <pod-name> -n youtube-clone-prod

# Describe pod for events
kubectl describe pod <pod-name> -n youtube-clone-prod
```

#### 2. Ingress Not Working
```bash
# Check ingress status
kubectl get ingress -n youtube-clone-prod

# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

#### 3. SSL Certificate Issues
```bash
# Check certificate status
kubectl get certificate -n youtube-clone-prod

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

### Debugging Commands

```bash
# Get all resources in namespace
kubectl get all -n youtube-clone-prod

# Check events
kubectl get events -n youtube-clone-prod --sort-by='.lastTimestamp'

# Port forward for local testing
kubectl port-forward service/youtube-clone-service 8080:80 -n youtube-clone-prod

# Execute into container
kubectl exec -it deployment/youtube-clone -n youtube-clone-prod -- sh
```

## 🔄 Rollback

### Automatic Rollback

The deployment includes:
- Rolling update strategy
- Pod Disruption Budget (PDB)
- Health checks for automatic rollback

### Manual Rollback

```bash
# View rollout history
kubectl rollout history deployment/youtube-clone -n youtube-clone-prod

# Rollback to previous version
kubectl rollout undo deployment/youtube-clone -n youtube-clone-prod

# Rollback to specific revision
kubectl rollout undo deployment/youtube-clone --to-revision=2 -n youtube-clone-prod
```

### Using Deployment Script

```bash
./scripts/deploy.sh production latest --rollback
```

## 📋 Maintenance

### Regular Tasks

1. **Update dependencies**: Keep base images and dependencies updated
2. **Security patches**: Apply security updates regularly
3. **Certificate renewal**: Automatic via cert-manager
4. **Backup**: Backup persistent data and configurations
5. **Monitoring**: Review metrics and alerts regularly

### Cleanup

```bash
# Delete specific environment
kubectl delete namespace youtube-clone-dev

# Clean up unused resources
kubectl delete pods --field-selector=status.phase=Succeeded -n youtube-clone-prod
```

## 🆘 Support

### Getting Help

1. Check the logs first
2. Review the troubleshooting section
3. Check Kubernetes events
4. Verify network connectivity
5. Review resource quotas and limits

### Useful Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)

---

## 📞 Contact

For deployment issues or questions, please:
1. Check the troubleshooting guide
2. Review application logs
3. Create an issue in the repository
4. Contact the DevOps team

---

**Happy Deploying! 🚀**
