#!/bin/sh

# Setup git hooks for the project

HOOK_DIR=".git/hooks"

# Create pre-commit hook
cat > "$HOOK_DIR/pre-commit" << 'EOF'
#!/bin/sh

# Pre-commit hook to format Dart files

echo "Running dart format..."

# Format all staged Dart files
dart format .

# Add any reformatted files back to staging
git add -u

echo "Dart formatting complete."
EOF

chmod +x "$HOOK_DIR/pre-commit"

echo "Git hooks installed successfully!"
