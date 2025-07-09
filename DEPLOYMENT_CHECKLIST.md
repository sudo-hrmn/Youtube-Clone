# 🚀 YouTube Clone Deployment Checklist

## Pre-Deployment Setup

### ✅ Local Development
- [ ] Node.js 18+ installed
- [ ] Docker installed and running
- [ ] Git repository initialized
- [ ] Dependencies installed (`npm install`)
- [ ] Tests passing (`npm run test:run`)
- [ ] Docker build successful (`docker build -t youtube-clone .`)
- [ ] Local container runs (`docker run -p 8080:80 youtube-clone`)

### ✅ GitHub Repository
- [ ] Repository created on GitHub
- [ ] Code pushed to main branch
- [ ] Repository is public or has proper access permissions
- [ ] GitHub Container Registry enabled

### ✅ GitHub Secrets Configuration
Navigate to: Repository → Settings → Secrets and variables → Actions

**Required Secrets:**
- [ ] `SONAR_TOKEN` - SonarCloud project token
- [ ] `SLACK_WEBHOOK_URL` - Slack notification webhook (optional)
- [ ] `KUBE_CONFIG_DEV` - Base64 encoded kubeconfig for development cluster
- [ ] `KUBE_CONFIG_STAGING` - Base64 encoded kubeconfig for staging cluster
- [ ] `KUBE_CONFIG_PROD` - Base64 encoded kubeconfig for production cluster

**Auto-generated Secrets (GitHub provides):**
- [ ] `GITHUB_TOKEN` - Automatically available

## External Services Setup

### ✅ SonarCloud Integration
- [ ] Account created at https://sonarcloud.io
- [ ] GitHub integration enabled
- [ ] Project imported from GitHub
- [ ] Project token generated and added to GitHub secrets
- [ ] Quality gate configured

### ✅ Slack Integration (Optional)
- [ ] Slack workspace available
- [ ] Incoming webhook created
- [ ] Webhook URL added to GitHub secrets

## Kubernetes Infrastructure

### ✅ Cluster Setup
Choose one option:
- [ ] **Local**: minikube, kind, or Docker Desktop Kubernetes
- [ ] **Cloud**: EKS (AWS), GKE (Google Cloud), AKS (Azure)
- [ ] **Managed**: DigitalOcean, Linode, or other managed Kubernetes

### ✅ Required Tools Installation
```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl

# kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

- [ ] `kubectl` installed and configured
- [ ] `kustomize` installed
- [ ] `helm` installed
- [ ] Cluster connection verified (`kubectl cluster-info`)

### ✅ Cluster Components
- [ ] **Namespaces created:**
  ```bash
  kubectl create namespace youtube-clone-dev
  kubectl create namespace youtube-clone-staging
  kubectl create namespace youtube-clone-prod
  kubectl create namespace ingress-nginx
  kubectl create namespace cert-manager
  ```

- [ ] **NGINX Ingress Controller:**
  ```bash
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
  ```

- [ ] **cert-manager for SSL:**
  ```bash
  helm repo add jetstack https://charts.jetstack.io
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
  ```

- [ ] **Load Balancer IP obtained** (for cloud clusters)

## Domain and DNS Configuration

### ✅ Domain Setup
- [ ] Domain name purchased/available
- [ ] DNS management access available

### ✅ DNS Records
Point these subdomains to your cluster's load balancer IP:
- [ ] `youtube-clone-dev.yourdomain.com` → CLUSTER_IP
- [ ] `youtube-clone-staging.yourdomain.com` → CLUSTER_IP
- [ ] `youtube-clone.yourdomain.com` → CLUSTER_IP

### ✅ Update Kubernetes Manifests
- [ ] Replace `yourdomain.com` in all ingress files with your actual domain
- [ ] Update certificate issuer email in cert-manager configuration

## Security Configuration

### ✅ Kubeconfig for GitHub Actions
- [ ] Service account created for GitHub Actions
- [ ] Appropriate RBAC permissions granted
- [ ] Kubeconfig files generated for each environment
- [ ] Kubeconfig files base64 encoded and added to GitHub secrets

### ✅ Container Registry Access
- [ ] GitHub Container Registry permissions configured
- [ ] Image pull secrets created (if using private registry)

## Deployment Verification

### ✅ Manual Deployment Test
Test each environment manually before CI/CD:

**Development:**
```bash
cd kubernetes/overlays/development
kubectl apply -k .
kubectl get pods -n youtube-clone-dev
kubectl port-forward svc/youtube-clone 8080:80 -n youtube-clone-dev
curl http://localhost:8080/health
```

**Staging:**
```bash
cd kubernetes/overlays/staging
kubectl apply -k .
kubectl get pods -n youtube-clone-staging
```

**Production:**
```bash
cd kubernetes/overlays/production
kubectl apply -k .
kubectl get pods -n youtube-clone-prod
```

- [ ] Development deployment successful
- [ ] Staging deployment successful
- [ ] Production deployment successful
- [ ] Health checks passing in all environments
- [ ] Applications accessible via configured domains

## CI/CD Pipeline Testing

### ✅ GitHub Actions Workflow
- [ ] Workflow file exists (`.github/workflows/ci-cd.yml`)
- [ ] All required secrets are set
- [ ] SonarCloud integration working

### ✅ Pipeline Stages Testing
- [ ] **Security Scan**: SonarCloud analysis passes
- [ ] **Tests**: Unit and integration tests pass
- [ ] **Build**: Application builds successfully
- [ ] **Docker**: Image builds and security scan passes
- [ ] **Deploy Dev**: PR deployments work
- [ ] **Deploy Staging**: Main branch deployments work
- [ ] **Deploy Prod**: Manual approval and deployment work

### ✅ End-to-End Testing
- [ ] Create test PR and verify development deployment
- [ ] Merge PR to main and verify staging deployment
- [ ] Approve production deployment and verify
- [ ] All environments accessible via URLs
- [ ] Health checks passing
- [ ] SSL certificates working

## Monitoring and Observability (Optional)

### ✅ Prometheus & Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

- [ ] Prometheus installed
- [ ] Grafana installed
- [ ] Dashboards configured
- [ ] Alerts configured

## Post-Deployment

### ✅ Documentation
- [ ] Update README.md with deployment URLs
- [ ] Document any environment-specific configurations
- [ ] Create runbooks for common operations

### ✅ Backup and Recovery
- [ ] Database backup strategy (if applicable)
- [ ] Configuration backup
- [ ] Disaster recovery plan

### ✅ Performance Testing
- [ ] Load testing performed
- [ ] Performance benchmarks established
- [ ] Scaling policies tested

## Troubleshooting Quick Reference

### Common Issues:
1. **Pipeline Failures**: Check GitHub Actions logs
2. **Deployment Issues**: `kubectl describe pod <pod-name> -n <namespace>`
3. **DNS Issues**: Verify DNS propagation with `nslookup`
4. **SSL Issues**: Check cert-manager logs
5. **Image Pull Issues**: Verify registry permissions

### Debug Commands:
```bash
# Check pod status
kubectl get pods -A

# View logs
kubectl logs -f deployment/youtube-clone -n youtube-clone-prod

# Check ingress
kubectl get ingress -A

# Check certificates
kubectl get certificates -A

# View events
kubectl get events --sort-by='.lastTimestamp' -A
```

---

## 🎉 Success Criteria

Your deployment is successful when:
- [ ] All CI/CD pipeline stages pass
- [ ] Applications are accessible via configured domains
- [ ] SSL certificates are valid
- [ ] Health checks return 200 OK
- [ ] Monitoring is collecting metrics
- [ ] Logs are being collected
- [ ] Scaling works as expected

**🚀 Congratulations! Your YouTube Clone is now running with enterprise-grade DevOps practices!**
