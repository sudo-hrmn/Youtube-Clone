#!/bin/bash

# GitHub Environment Setup Script
# Professional setup for GitHub Container Registry

echo "🔧 GitHub Container Registry Setup"
echo "=================================="
echo ""

echo "To complete the GitHub Container Registry setup, you need:"
echo ""
echo "1. GitHub Personal Access Token with 'packages:read' and 'packages:write' permissions"
echo "   - Go to: https://github.com/settings/tokens"
echo "   - Click 'Generate new token (classic)'"
echo "   - Select scopes: repo, write:packages, read:packages"
echo ""
echo "2. Your email address associated with GitHub"
echo ""
echo "Then run these commands:"
echo ""
echo "export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx"
echo "export EMAIL=your-email@example.com"
echo ""
echo "After setting the variables, run:"
echo "./setup-github-registry.sh all"
echo ""
echo "Or for step-by-step setup:"
echo "./setup-github-registry.sh help"
