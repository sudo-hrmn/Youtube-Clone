# YouTube Clone - Complete Setup Guide

## 🔧 Step-by-Step Setup Instructions

### 1. GitHub Repository Setup

#### A. Create GitHub Repository
```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit: YouTube Clone with DevOps setup"

# Add remote origin (replace with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/youtube-clone.git
git branch -M main
git push -u origin main
```

#### B. Configure GitHub Secrets
Go to your GitHub repository → Settings → Secrets and variables → Actions

**Required Secrets:**
```
SONAR_TOKEN=your_sonarcloud_token
SLACK_WEBHOOK_URL=your_slack_webhook_url
KUBE_CONFIG_DEV=base64_encoded_kubeconfig_for_dev
KUBE_CONFIG_STAGING=base64_encoded_kubeconfig_for_staging  
KUBE_CONFIG_PROD=base64_encoded_kubeconfig_for_production
```

### 2. SonarCloud Integration

#### A. Setup SonarCloud Project
1. Go to https://sonarcloud.io
2. Sign in with GitHub
3. Import your repository
4. Get your project token
5. Add token to GitHub secrets as `SONAR_TOKEN`

#### B. Create SonarCloud Configuration
```bash
# This file should be created in project root
```

### 3. Kubernetes Cluster Setup

#### A. Choose Your Kubernetes Platform
- **Local Development**: minikube, kind, or Docker Desktop
- **Cloud Providers**: EKS (AWS), GKE (Google), AKS (Azure)
- **Managed**: DigitalOcean Kubernetes, Linode LKE

#### B. Install Required Tools
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# Install helm (for cert-manager and ingress)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 4. Cluster Infrastructure Setup

#### A. Create Namespaces
```bash
kubectl create namespace youtube-clone-dev
kubectl create namespace youtube-clone-staging  
kubectl create namespace youtube-clone-prod
kubectl create namespace cert-manager
kubectl create namespace ingress-nginx
```

#### B. Install NGINX Ingress Controller
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

#### C. Install cert-manager for SSL
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

### 5. Domain and DNS Configuration

#### A. Configure DNS Records
Point your domains to your cluster's load balancer IP:
```
youtube-clone-dev.yourdomain.com → CLUSTER_IP
youtube-clone-staging.yourdomain.com → CLUSTER_IP  
youtube-clone.yourdomain.com → CLUSTER_IP
```

#### B. Update Kubernetes Manifests
Replace `yourdomain.com` in all ingress files with your actual domain.

### 6. Monitoring Setup (Optional but Recommended)

#### A. Install Prometheus & Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### 7. Security Configuration

#### A. Create Service Account for GitHub Actions
```bash
kubectl create serviceaccount github-actions -n youtube-clone-prod
kubectl create clusterrolebinding github-actions \
  --clusterrole=cluster-admin \
  --serviceaccount=youtube-clone-prod:github-actions
```

#### B. Generate Kubeconfig for GitHub Actions
```bash
# Get service account token and create kubeconfig
# Encode with base64 and add to GitHub secrets
```

### 8. Test Local Development

#### A. Run Tests
```bash
npm install
npm run test:run
npm run test:coverage
```

#### B. Test Docker Build
```bash
docker build -t youtube-clone:test .
docker run -p 8080:80 youtube-clone:test
```

### 9. Deploy to Kubernetes

#### A. Manual Deployment Test
```bash
cd kubernetes/overlays/development
kubectl apply -k .
kubectl get pods -n youtube-clone-dev
```

#### B. Verify Deployment
```bash
kubectl port-forward svc/youtube-clone 8080:80 -n youtube-clone-dev
curl http://localhost:8080/health
```

### 10. Trigger CI/CD Pipeline

#### A. Create Pull Request
```bash
git checkout -b feature/test-deployment
git push origin feature/test-deployment
# Create PR on GitHub
```

#### B. Merge to Main
```bash
# After PR approval, merge to main
# This will trigger staging deployment
```

## 🔍 Verification Checklist

- [ ] GitHub repository created and configured
- [ ] All GitHub secrets added
- [ ] SonarCloud project setup
- [ ] Kubernetes cluster running
- [ ] Ingress controller installed
- [ ] cert-manager installed
- [ ] DNS records configured
- [ ] Namespaces created
- [ ] Local tests passing
- [ ] Docker build successful
- [ ] Manual Kubernetes deployment works
- [ ] CI/CD pipeline triggers correctly
- [ ] All environments accessible via URLs

## 🚨 Troubleshooting

### Common Issues:
1. **Kubeconfig Issues**: Ensure base64 encoding is correct
2. **DNS Problems**: Check domain propagation
3. **SSL Certificate Issues**: Verify cert-manager is running
4. **Image Pull Errors**: Check GitHub Container Registry permissions
5. **Resource Limits**: Ensure cluster has sufficient resources

### Debug Commands:
```bash
# Check pod status
kubectl get pods -n youtube-clone-dev

# View logs
kubectl logs -f deployment/youtube-clone -n youtube-clone-dev

# Describe resources
kubectl describe ingress youtube-clone -n youtube-clone-dev

# Check events
kubectl get events -n youtube-clone-dev --sort-by='.lastTimestamp'
```

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section
2. Review GitHub Actions logs
3. Verify Kubernetes cluster status
4. Check domain DNS configuration
5. Validate all secrets are properly set

---

**🎉 Once completed, you'll have a fully automated, enterprise-grade YouTube Clone deployment!**
