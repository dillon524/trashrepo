#!/bin/bash

# Determine the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
elif command -v lsb_release &> /dev/null; then
    DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
else
    echo "Cannot determine Linux distribution. Exiting."
    exit 1
fi

# Perform verification and upgrades based on distribution
echo "Detected Linux distribution: $DISTRO"

if [[ "$DISTRO" == "debian" || "$DISTRO" == "ubuntu" ]]; then
    echo "Verifying packages with dpkg..."
    dpkg --verify
    echo "Upgrading packages with apt..."
    sudo apt update && sudo apt full-upgrade -y
elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rocky" || "$DISTRO" == "rhel" ]]; then
    echo "Verifying packages with rpm..."
    rpm -Va
    echo "Upgrading packages with yum..."
    sudo yum update -y
elif [[ "$DISTRO" == "fedora" ]]; then
    echo "Verifying packages with rpm..."
    rpm -Va
    echo "Upgrading packages with dnf..."
    sudo dnf upgrade --refresh -y
else
    echo "Unsupported distribution: $DISTRO"
    exit 1
fi
