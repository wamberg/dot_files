#!/usr/bin/env bash
# nixmac-maintenance.sh - nix-darwin maintenance script for macOS

set -e  # Exit on error

echo "======================================"
echo "  nix-darwin System Maintenance"
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

echo ""
print_step "Listing current nix-darwin generations..."
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
echo ""
current_gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
echo "Current generation: $current_gen"

echo ""
print_step "Cleaning old nix-darwin generations (keeping last 2)..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
echo "Old system generations deleted."

echo ""
print_step "Cleaning old home-manager generations (keeping last 2)..."
HM_PROFILE="/nix/var/nix/profiles/per-user/$USER/home-manager"
if [ -e "$HM_PROFILE" ]; then
    nix-env --profile "$HM_PROFILE" --delete-generations +2
    echo "Old home-manager generations deleted."
else
    echo "Home-manager integrated with system generations."
fi

echo ""
print_step "Running garbage collection..."
echo "Before:"
du -sh /nix/store
sudo nix-collect-garbage
echo ""
echo "After:"
du -sh /nix/store

echo ""
print_step "Optimizing Nix store (deduplication)..."
sudo nix-store --optimise

echo ""
print_step "Verifying Nix store integrity..."
if sudo nix-store --verify --check-contents 2>&1 | grep -q "error:"; then
    print_error "Nix store verification found issues!"
    sudo nix-store --verify --check-contents
else
    echo "Nix store integrity verified."
fi

echo ""
echo "======================================"
echo -e "${GREEN}  Maintenance Complete!${NC}"
echo "======================================"
