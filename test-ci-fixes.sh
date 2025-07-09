#!/bin/bash

echo "🧪 Testing CI/CD Fixes..."
echo "=========================="

# Check Node.js version
echo "📋 Node.js version:"
node --version

# Install dependencies
echo "📦 Installing dependencies..."
npm ci

# Run linting
echo "🔍 Running ESLint..."
npm run lint

# Run tests
echo "🧪 Running tests..."
npm run test:run

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed. Check the output above."
    exit 1
fi

echo "🎉 CI/CD fixes validation complete!"
