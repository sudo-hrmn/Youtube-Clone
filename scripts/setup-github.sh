#!/bin/bash

# GitHub Repository Setup Script for YouTube Clone
# This script helps set up the GitHub repository with all necessary configurations

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Repository details
REPO_URL="https://github.com/sudo-hrmn/Youtube-Clone"
REPO_NAME="Youtube-Clone"
GITHUB_USER="sudo-hrmn"

echo -e "${BLUE}🚀 Setting up GitHub repository for YouTube Clone${NC}"

# Function to check if git is configured
check_git_config() {
  echo -e "${BLUE}🔍 Checking Git configuration...${NC}"
  
  if ! git config user.name &> /dev/null; then
    echo -e "${YELLOW}⚠️ Git user.name not configured${NC}"
    read -p "Enter your Git username: " git_username
    git config --global user.name "$git_username"
  fi
  
  if ! git config user.email &> /dev/null; then
    echo -e "${YELLOW}⚠️ Git user.email not configured${NC}"
    read -p "Enter your Git email: " git_email
    git config --global user.email "$git_email"
  fi
  
  echo -e "${GREEN}✅ Git configuration verified${NC}"
}

# Function to initialize git repository
init_git_repo() {
  echo -e "${BLUE}📁 Initializing Git repository...${NC}"
  
  if [ ! -d ".git" ]; then
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
  else
    echo -e "${YELLOW}⚠️ Git repository already exists${NC}"
  fi
}

# Function to create .gitignore if it doesn't exist
create_gitignore() {
  echo -e "${BLUE}📝 Creating .gitignore file...${NC}"
  
  if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production build
dist/
build/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs
*.log

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Kubernetes secrets
kubeconfig
*.kubeconfig

# Terraform
*.tfstate
*.tfstate.*
.terraform/

# Helm
charts/*.tgz

# Test results
test-results.xml
junit.xml
EOF
    echo -e "${GREEN}✅ .gitignore file created${NC}"
  else
    echo -e "${YELLOW}⚠️ .gitignore file already exists${NC}"
  fi
}

# Function to add remote origin
add_remote_origin() {
  echo -e "${BLUE}🔗 Adding remote origin...${NC}"
  
  if ! git remote get-url origin &> /dev/null; then
    git remote add origin "$REPO_URL.git"
    echo -e "${GREEN}✅ Remote origin added${NC}"
  else
    current_origin=$(git remote get-url origin)
    if [ "$current_origin" != "$REPO_URL.git" ]; then
      echo -e "${YELLOW}⚠️ Different remote origin exists: $current_origin${NC}"
      read -p "Do you want to update it to $REPO_URL.git? [y/N]: " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url origin "$REPO_URL.git"
        echo -e "${GREEN}✅ Remote origin updated${NC}"
      fi
    else
      echo -e "${GREEN}✅ Remote origin already configured correctly${NC}"
    fi
  fi
}

# Function to create initial commit
create_initial_commit() {
  echo -e "${BLUE}📝 Creating initial commit...${NC}"
  
  # Add all files
  git add .
  
  # Check if there are changes to commit
  if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️ No changes to commit${NC}"
  else
    git commit -m "feat: initial commit with YouTube Clone application

- Add React-based YouTube clone application
- Add Docker multi-stage build configuration
- Add Kubernetes deployment manifests
- Add CI/CD pipeline with GitHub Actions
- Add comprehensive testing suite with Vitest
- Add deployment scripts and documentation
- Add security configurations and best practices"
    echo -e "${GREEN}✅ Initial commit created${NC}"
  fi
}

# Function to create and push branches
create_branches() {
  echo -e "${BLUE}🌿 Creating development branches...${NC}"
  
  # Create develop branch
  if ! git show-ref --verify --quiet refs/heads/develop; then
    git checkout -b develop
    echo -e "${GREEN}✅ Created develop branch${NC}"
  else
    echo -e "${YELLOW}⚠️ Develop branch already exists${NC}"
  fi
  
  # Create staging branch
  if ! git show-ref --verify --quiet refs/heads/staging; then
    git checkout -b staging
    echo -e "${GREEN}✅ Created staging branch${NC}"
  else
    echo -e "${YELLOW}⚠️ Staging branch already exists${NC}"
  fi
  
  # Switch back to main
  git checkout main 2>/dev/null || git checkout master
}

# Function to push to GitHub
push_to_github() {
  echo -e "${BLUE}⬆️ Pushing to GitHub...${NC}"
  
  # Push main branch
  if git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null; then
    echo -e "${GREEN}✅ Main branch pushed successfully${NC}"
  else
    echo -e "${RED}❌ Failed to push main branch${NC}"
    echo "Please check your GitHub credentials and repository access"
    return 1
  fi
  
  # Push develop branch
  if git push -u origin develop 2>/dev/null; then
    echo -e "${GREEN}✅ Develop branch pushed successfully${NC}"
  else
    echo -e "${YELLOW}⚠️ Could not push develop branch${NC}"
  fi
  
  # Push staging branch
  if git push -u origin staging 2>/dev/null; then
    echo -e "${GREEN}✅ Staging branch pushed successfully${NC}"
  else
    echo -e "${YELLOW}⚠️ Could not push staging branch${NC}"
  fi
}

# Function to display GitHub setup instructions
show_github_instructions() {
  echo -e "${BLUE}📋 GitHub Repository Setup Instructions${NC}"
  echo ""
  echo -e "${YELLOW}1. Repository Secrets Setup:${NC}"
  echo "   Go to: $REPO_URL/settings/secrets/actions"
  echo "   Add the following secrets:"
  echo ""
  echo "   🔐 Required Secrets:"
  echo "   • GITHUB_TOKEN (automatically available)"
  echo "   • KUBE_CONFIG_DEV (base64 encoded kubeconfig for development)"
  echo "   • KUBE_CONFIG_STAGING (base64 encoded kubeconfig for staging)"
  echo "   • KUBE_CONFIG_PROD (base64 encoded kubeconfig for production)"
  echo ""
  echo "   🔐 Optional Secrets:"
  echo "   • SONAR_TOKEN (for SonarCloud integration)"
  echo "   • SLACK_WEBHOOK_URL (for deployment notifications)"
  echo ""
  echo -e "${YELLOW}2. Branch Protection Rules:${NC}"
  echo "   Go to: $REPO_URL/settings/branches"
  echo "   Set up protection for 'main' branch:"
  echo "   • Require pull request reviews"
  echo "   • Require status checks to pass"
  echo "   • Require branches to be up to date"
  echo "   • Include administrators"
  echo ""
  echo -e "${YELLOW}3. GitHub Pages (Optional):${NC}"
  echo "   Go to: $REPO_URL/settings/pages"
  echo "   Configure GitHub Pages for documentation"
  echo ""
  echo -e "${YELLOW}4. Repository Settings:${NC}"
  echo "   • Enable Issues and Projects"
  echo "   • Set up repository topics: react, docker, kubernetes, devops"
  echo "   • Configure repository description"
  echo ""
  echo -e "${GREEN}🎉 Repository URL: $REPO_URL${NC}"
}

# Function to create GitHub workflows directory structure
setup_github_workflows() {
  echo -e "${BLUE}⚙️ Setting up GitHub workflows...${NC}"
  
  if [ ! -d ".github/workflows" ]; then
    mkdir -p .github/workflows
    echo -e "${GREEN}✅ GitHub workflows directory created${NC}"
  fi
  
  # The CI/CD workflow should already exist from previous steps
  if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo -e "${GREEN}✅ CI/CD workflow already configured${NC}"
  else
    echo -e "${YELLOW}⚠️ CI/CD workflow not found${NC}"
  fi
}

# Function to create issue templates
create_issue_templates() {
  echo -e "${BLUE}📝 Creating issue templates...${NC}"
  
  mkdir -p .github/ISSUE_TEMPLATE
  
  # Bug report template
  cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - OS: [e.g. iOS]
 - Browser [e.g. chrome, safari]
 - Version [e.g. 22]

**Additional context**
Add any other context about the problem here.
EOF

  # Feature request template
  cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
EOF

  echo -e "${GREEN}✅ Issue templates created${NC}"
}

# Function to create pull request template
create_pr_template() {
  echo -e "${BLUE}📝 Creating pull request template...${NC}"
  
  mkdir -p .github
  
  cat > .github/pull_request_template.md << 'EOF'
## Description
Brief description of the changes in this PR.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Security scan passed

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Additional Notes
Any additional information or context about the PR.
EOF

  echo -e "${GREEN}✅ Pull request template created${NC}"
}

# Main execution
main() {
  echo -e "${BLUE}🎬 YouTube Clone GitHub Setup${NC}"
  echo "Repository: $REPO_URL"
  echo ""
  
  # Check if we're in the right directory
  if [ ! -f "package.json" ] || ! grep -q "youtube-clone" package.json; then
    echo -e "${RED}❌ This doesn't appear to be the YouTube Clone project directory${NC}"
    echo "Please run this script from the project root directory"
    exit 1
  fi
  
  # Run setup steps
  check_git_config
  init_git_repo
  create_gitignore
  setup_github_workflows
  create_issue_templates
  create_pr_template
  add_remote_origin
  create_initial_commit
  create_branches
  
  # Ask if user wants to push to GitHub
  echo ""
  read -p "Do you want to push the repository to GitHub now? [y/N]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    push_to_github
  else
    echo -e "${YELLOW}⚠️ Skipping GitHub push. You can push manually later with:${NC}"
    echo "git push -u origin main"
    echo "git push -u origin develop"
    echo "git push -u origin staging"
  fi
  
  echo ""
  show_github_instructions
  
  echo ""
  echo -e "${GREEN}🎉 GitHub repository setup completed!${NC}"
  echo -e "${BLUE}Next steps:${NC}"
  echo "1. Configure repository secrets in GitHub"
  echo "2. Set up branch protection rules"
  echo "3. Configure your Kubernetes clusters"
  echo "4. Test the CI/CD pipeline"
}

# Run main function
main "$@"
