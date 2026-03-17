#!/usr/bin/env bash
# mac-maintenance.sh - macOS weekly maintenance script

set -e

echo "======================================"
echo "  macOS Weekly Maintenance"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Update Homebrew and upgrade all packages
print_step "Updating Homebrew and upgrading formulae..."
brew update
brew upgrade

echo ""
print_step "Upgrading Homebrew casks..."
brew upgrade --cask --greedy || print_warning "Some cask upgrades failed. You may need to retry or upgrade them manually."

echo ""
print_step "Cleaning up Homebrew cache and old versions..."
brew cleanup --prune=30
brew autoremove

echo ""
print_step "Checking for Homebrew issues..."
brew doctor || true

echo ""
print_step "Checking mise-controlled tools..."
mise outdated --bump
read -rp "Did you update any versions in mise config? (y/N): " update_mise
if [[ "$update_mise" =~ ^[Yy]$ ]]; then
    mise install
    mise prune
fi

echo ""
print_step "Cleaning Docker resources..."
if docker info &>/dev/null; then
    echo "Pruning unused Docker resources..."
    docker system prune -f
else
    echo "Docker not running, skipping."
fi

echo ""
print_step "Checking disk usage..."
df -h /

echo ""
echo "======================================"
echo -e "${GREEN}  Maintenance Complete!${NC}"
echo "======================================"
