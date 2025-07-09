#!/bin/bash

# YouTube Clone Local Test Script
echo "🚀 YouTube Clone Local Test Suite"
echo "=================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\n${BLUE}Option 1: Docker Test${NC}"
echo "====================="

# Check if Docker container is running
if docker ps | grep -q youtube-clone-local; then
    echo -e "${GREEN}✅ Docker container is already running${NC}"
    echo "🌐 Application URL: http://localhost:8080"
    echo "🔍 Health Check: http://localhost:8080/health"
    
    echo -e "\n📊 Testing endpoints:"
    curl -f http://localhost:8080/health && echo " ✅ Health check passed"
    curl -I http://localhost:8080/ | head -1 && echo " ✅ Main application accessible"
else
    echo "❌ Docker container not running. Starting..."
    docker run -d -p 8080:80 --name youtube-clone-local youtube-clone:latest
    sleep 3
    echo -e "${GREEN}✅ Docker container started${NC}"
    echo "🌐 Application URL: http://localhost:8080"
fi

echo -e "\n${BLUE}Option 2: Kubernetes Test (Minikube)${NC}"
echo "====================================="

# Check if minikube is running
if minikube status | grep -q "Running"; then
    echo -e "${GREEN}✅ Minikube is running${NC}"
    
    # Check if deployment exists
    if minikube kubectl -- get deployment youtube-clone -n youtube-clone-dev >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Kubernetes deployment is running${NC}"
        
        # Get pod status
        POD_STATUS=$(minikube kubectl -- get pods -n youtube-clone-dev --no-headers | awk '{print $3}')
        if [ "$POD_STATUS" = "Running" ]; then
            echo -e "${GREEN}✅ Pod is healthy${NC}"
            
            echo -e "\n📊 Testing Kubernetes deployment:"
            echo "🔧 Port forwarding to test..."
            minikube kubectl -- port-forward svc/youtube-clone-service 8081:80 -n youtube-clone-dev &
            PF_PID=$!
            sleep 3
            
            curl -f http://localhost:8081/health >/dev/null 2>&1 && echo "✅ Kubernetes health check passed"
            curl -I http://localhost:8081/ >/dev/null 2>&1 && echo "✅ Kubernetes main application accessible"
            
            kill $PF_PID 2>/dev/null
            echo "🌐 To access via port-forward: minikube kubectl -- port-forward svc/youtube-clone-service 8081:80 -n youtube-clone-dev"
        else
            echo "❌ Pod status: $POD_STATUS"
        fi
    else
        echo "❌ Kubernetes deployment not found"
        echo "💡 Run: cd kubernetes/overlays/development && minikube kubectl -- apply -k ."
    fi
else
    echo "❌ Minikube not running"
    echo "💡 Run: minikube start"
fi

echo -e "\n${BLUE}Option 3: Development Server${NC}"
echo "============================"
echo "🔧 To run development server:"
echo "   npm run dev"
echo "🌐 Development URL: http://localhost:5173"

echo -e "\n${YELLOW}📋 Quick Access URLs:${NC}"
echo "🐳 Docker:     http://localhost:8080"
echo "☸️  Kubernetes: minikube kubectl -- port-forward svc/youtube-clone-service 8081:80 -n youtube-clone-dev"
echo "⚡ Development: npm run dev (http://localhost:5173)"

echo -e "\n${GREEN}🎉 Local testing setup complete!${NC}"
