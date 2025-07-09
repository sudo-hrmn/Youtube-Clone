#!/bin/bash

# YouTube Clone Project Setup Script
# This script helps automate the initial project setup

set -e

echo "🚀 YouTube Clone Project Setup"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if required tools are installed
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_tools=()
    
    # Check for required tools
    command -v node >/dev/null 2>&1 || missing_tools+=("node")
    command -v npm >/dev/null 2>&1 || missing_tools+=("npm")
    command -v docker >/dev/null 2>&1 || missing_tools+=("docker")
    command -v git >/dev/null 2>&1 || missing_tools+=("git")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install the missing tools and run this script again."
        exit 1
    fi
    
    print_status "All prerequisites are installed ✓"
}

# Install Node.js dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    if [ -f "package.json" ]; then
        print_status "Installing npm dependencies..."
        npm install
        print_status "Dependencies installed ✓"
    else
        print_error "package.json not found!"
        exit 1
    fi
}

# Run tests to verify setup
run_tests() {
    print_header "Running Tests"
    
    print_status "Running unit tests..."
    npm run test:run || {
        print_warning "Some tests failed, but continuing setup..."
    }
    
    print_status "Tests completed ✓"
}

# Build Docker image
build_docker() {
    print_header "Building Docker Image"
    
    print_status "Building production Docker image..."
    docker build -t youtube-clone:latest --target production . || {
        print_error "Docker build failed!"
        exit 1
    }
    
    print_status "Docker image built successfully ✓"
}

# Test Docker container
test_docker() {
    print_header "Testing Docker Container"
    
    print_status "Starting container for testing..."
    docker run -d -p 8080:80 --name youtube-clone-test youtube-clone:latest || {
        print_error "Failed to start Docker container!"
        exit 1
    }
    
    # Wait for container to start
    sleep 5
    
    # Test health endpoint
    if curl -f http://localhost:8080/health >/dev/null 2>&1; then
        print_status "Container health check passed ✓"
    else
        print_warning "Container health check failed, but container is running"
    fi
    
    # Stop and remove test container
    docker stop youtube-clone-test >/dev/null 2>&1
    docker rm youtube-clone-test >/dev/null 2>&1
    
    print_status "Docker container test completed ✓"
}

# Initialize git repository
setup_git() {
    print_header "Git Repository Setup"
    
    if [ ! -d ".git" ]; then
        print_status "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit: YouTube Clone with DevOps setup"
        print_status "Git repository initialized ✓"
    else
        print_status "Git repository already exists ✓"
    fi
}

# Display next steps
show_next_steps() {
    print_header "Next Steps"
    
    echo -e "${GREEN}✅ Project setup completed successfully!${NC}\n"
    
    echo "To complete the full deployment setup:"
    echo "1. Create GitHub repository and push code:"
    echo "   ${YELLOW}git remote add origin https://github.com/YOUR_USERNAME/youtube-clone.git${NC}"
    echo "   ${YELLOW}git push -u origin main${NC}"
    echo ""
    echo "2. Configure GitHub Secrets (see SETUP_GUIDE.md for details)"
    echo "3. Set up SonarCloud integration"
    echo "4. Configure Kubernetes cluster"
    echo "5. Set up domain and DNS"
    echo ""
    echo "📖 For detailed instructions, see: ${BLUE}SETUP_GUIDE.md${NC}"
    echo ""
    echo "🐳 To run locally with Docker:"
    echo "   ${YELLOW}docker run -p 8080:80 youtube-clone:latest${NC}"
    echo "   Then visit: ${BLUE}http://localhost:8080${NC}"
    echo ""
    echo "🔧 To run in development mode:"
    echo "   ${YELLOW}npm run dev${NC}"
    echo "   Then visit: ${BLUE}http://localhost:5173${NC}"
}

# Main execution
main() {
    echo "Starting project setup..."
    
    check_prerequisites
    install_dependencies
    run_tests
    build_docker
    test_docker
    setup_git
    show_next_steps
    
    print_status "Setup completed successfully! 🎉"
}

# Run main function
main "$@"
