#!/bin/sh

# Xcode Cloud post-clone script for Flutter apps
# This runs after the repo is cloned but before building

set -e

echo "=== Flutter Setup for Xcode Cloud ==="

# Navigate to project root
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Install Flutter using git
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# Disable analytics
flutter config --no-analytics

# Run Flutter doctor
echo "Running flutter doctor..."
flutter doctor -v

# Create .env file from Xcode Cloud environment variables
echo "Creating .env file..."
cat > .env << EOF
API_BASE_URL=${API_BASE_URL}
POLLING_INTERVAL=${POLLING_INTERVAL:-60}
WEBSOCKET_ENABLED=true
REVERB_HOST=ekstremedia.no
REVERB_PORT=443
REVERB_SCHEME=https
REVERB_APP_KEY=${REVERB_APP_KEY}
EOF

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Generate iOS build files
echo "Building iOS (no codesign)..."
flutter build ios --release --no-codesign

echo "=== Flutter Setup Complete ==="
