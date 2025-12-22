#!/usr/bin/env bash
# nixos-maintenance.sh - NixOS maintenance script

set -e  # Exit on error

echo "======================================"
echo "  NixOS System Maintenance"
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

# Path to NixOS flake
NIX_PATH="/home/wamberg/dev/dot_files/ops/nix"

# Update flake inputs
echo ""
print_step "Checking for flake input updates..."
cd "$NIX_PATH"
nix flake update
if git diff --quiet flake.lock; then
    echo "No updates available."
else
    echo "Flake inputs updated. Review changes:"
    git diff flake.lock
    echo ""
    read -rp "Rebuild system with updates? (y/N): " rebuild
    if [[ "$rebuild" =~ ^[Yy]$ ]]; then
        sudo nixos-rebuild switch --flake .#forge
    else
        echo "Skipping rebuild. Run 'nbuild' when ready."
        git restore flake.lock
    fi
fi

echo ""
print_step "Listing current NixOS generations..."
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
echo ""
current_gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
echo "Current generation: $current_gen"

echo ""
print_step "Cleaning old NixOS generations (keeping last 5)..."
read -rp "Delete generations older than 5? (y/N): " delete_gens
if [[ "$delete_gens" =~ ^[Yy]$ ]]; then
    sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
    echo "Old system generations deleted."
else
    echo "Keeping all generations."
fi

echo ""
print_step "Cleaning old home-manager generations (keeping last 5)..."
read -rp "Delete home-manager generations older than 5? (y/N): " delete_hm_gens
if [[ "$delete_hm_gens" =~ ^[Yy]$ ]]; then
    nix-env --profile /nix/var/nix/profiles/per-user/$USER/home-manager --delete-generations +5
    echo "Old home-manager generations deleted."
else
    echo "Keeping all home-manager generations."
fi

echo ""
print_step "Running garbage collection..."
echo "Before:"
du -sh /nix/store
sudo nix-collect-garbage -d
echo ""
echo "After:"
du -sh /nix/store

echo ""
print_step "Optimizing Nix store (deduplication)..."
sudo nix-store --optimise

echo ""
print_step "Cleaning systemd journal (keeping last 4 weeks)..."
sudo journalctl --vacuum-time=4weeks

echo ""
print_step "Checking /boot space..."
df -h /boot

echo ""
print_step "Verifying Nix store integrity..."
if sudo nix-store --verify --check-contents 2>&1 | grep -q "error:"; then
    print_error "Nix store verification found issues!"
    sudo nix-store --verify --check-contents
else
    echo "Nix store integrity verified."
fi

echo ""
print_step "Checking for failed system services..."
failed_system=$(systemctl --failed --no-pager --no-legend || true)
if [[ -n "$failed_system" ]]; then
    print_error "Failed system services:"
    systemctl --failed
else
    echo "No failed system services."
fi

echo ""
print_step "Checking for failed user services..."
failed_user=$(systemctl --user --failed --no-pager --no-legend || true)
if [[ -n "$failed_user" ]]; then
    print_error "Failed user services:"
    systemctl --user --failed
else
    echo "No failed user services."
fi

echo ""
echo "======================================"
echo -e "${GREEN}  Maintenance Complete!${NC}"
echo "======================================"
echo ""
echo "Optional tasks to consider:"
echo "  • Review disk usage: ncdu /"
echo "  • Backup important data"
echo ""
