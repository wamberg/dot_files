#!/bin/bash
# weekly-maintenance.sh - Arch Linux weekly maintenance script

set -e  # Exit on error

echo "======================================"
echo "  Arch Linux Weekly Maintenance"
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

# Update everything
print_step "Updating system packages and AUR packages..."
sudo -u aur_builder yay -Syu

echo ""
print_step "Cleaning AUR build cache..."
yay -Sc --noconfirm

echo ""
print_step "Cleaning orphaned packages..."
orphans=$(pacman -Qtdq 2>/dev/null || true)
if [[ -n "$orphans" ]]; then
    echo "Found orphaned packages:"
    echo "$orphans"
    sudo pacman -Rs "$orphans"
else
    echo "No orphaned packages found."
fi

echo ""
print_step "Cleaning package cache (keeping last 3 versions)..."
if command -v paccache &> /dev/null; then
    sudo paccache -r
    sudo paccache -ruk0  # Remove all uninstalled packages
else
    print_warning "paccache not found. Install with: sudo pacman -S pacman-contrib"
    sudo pacman -Sc --noconfirm
fi

echo ""
print_step "Cleaning Docker resources..."
if systemctl is-active --quiet docker; then
    echo "Pruning unused Docker resources..."
    docker system prune -f
    # Uncomment for aggressive cleaning (removes all unused images):
    # docker system prune -a -f --volumes
else
    echo "Docker service not running, skipping."
fi

echo ""
print_step "Cleaning systemd journal (keeping last 4 weeks)..."
sudo journalctl --vacuum-time=4weeks

echo ""
print_step "Checking mise-controlled tools..."
mise outdated --bump
read -rp "Did you update any versions in mise config? (y/N): " update_mise
if [[ "$update_mise" =~ ^[Yy]$ ]]; then
    mise install
    mise prune
fi

echo ""
print_step "Checking /boot space..."
df -h /boot

echo ""
print_step "Checking for .pacnew configuration files..."
pacnew_files=$(sudo find /etc -name "*.pacnew" 2>/dev/null || true)
if [[ -n "$pacnew_files" ]]; then
    print_warning "Found .pacnew files:"
    echo "$pacnew_files"
    echo ""
    echo "Review and merge these files manually with:"
    echo "  sudo DIFFPROG=\"$(nvim) -d\" pacdiff"
else
    echo "No .pacnew files found."
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
echo "Optional monthly tasks to consider:"
echo "  • Update mirrorlist: sudo reflector --country US --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
echo "  • Verify package database: sudo pacman -Dk"
echo "  • Check disk usage: ncdu /"
