#!/bin/bash

# Function to configure firewall on Debian/Ubuntu using UFW
configure_ubuntu_debian_firewall() {
    echo "Configuring firewall on Debian/Ubuntu..."
    
    # Check if UFW is installed; if not, install it
    if ! command -v ufw &> /dev/null; then
        echo "UFW not found. Installing UFW..."
        apt-get update -y
        apt-get install ufw -y
    fi

    # Set default policies
    ufw default deny incoming         # Deny all incoming traffic
    ufw default allow outgoing        # Allow all outgoing traffic

    # Open only the specified ports
    ufw allow 21/tcp       # Allow FTP
    ufw allow 22/tcp       # Allow SSH
    ufw allow 80/tcp       # Allow HTTP
    ufw allow 443/tcp      # Allow HTTPS
    ufw allow 3000/tcp     # Allow Grafana
    ufw allow 3306/tcp     # Allow MySQL

    # Enable UFW
    ufw enable             
    echo "Debian/Ubuntu firewall configured."
}

# Function to configure firewall on Rocky Linux using firewalld
configure_rocky_firewall() {
    echo "Configuring firewall on Rocky Linux..."
    
    # Check if firewalld is installed; if not, install it
    if ! command -v firewall-cmd &> /dev/null; then
        echo "firewalld not found. Installing firewalld..."
        yum install firewalld -y
        systemctl enable firewalld
        systemctl start firewalld
    fi

    # Set default zone to drop all incoming traffic by default
    firewall-cmd --set-default-zone=drop
    
    # Open only the specified ports and services
    firewall-cmd --permanent --add-port=21/tcp      # Allow FTP
    firewall-cmd --permanent --add-port=22/tcp      # Allow SSH
    firewall-cmd --permanent --add-service=http     # Allow HTTP
    firewall-cmd --permanent --add-service=https    # Allow HTTPS
    firewall-cmd --permanent --add-port=3000/tcp    # Allow Grafana
    firewall-cmd --permanent --add-port=3306/tcp    # Allow MySQL

    # Reload firewalld to apply changes
    firewall-cmd --reload
    echo "Rocky Linux firewall configured."
}

# Function to configure firewall on FreeBSD
configure_freebsd_firewall() {
    echo "Configuring firewall on FreeBSD..."

    # Check if pf is enabled in /etc/rc.conf, and enable it if not
    if ! grep -q "^pf_enable=\"YES\"" /etc/rc.conf; then
        echo "Enabling pf firewall..."
        echo "pf_enable=\"YES\"" >> /etc/rc.conf
    fi

    # Define pf rules to deny all incoming connections by default
    echo "block all" > /etc/pf.conf
    
    # Allow only the specified ports
    echo "pass in proto tcp from any to any port 21" >> /etc/pf.conf    # Allow FTP
    echo "pass in proto tcp from any to any port 22" >> /etc/pf.conf    # Allow SSH
    echo "pass in proto tcp from any to any port 80" >> /etc/pf.conf    # Allow HTTP
    echo "pass in proto tcp from any to any port 443" >> /etc/pf.conf   # Allow HTTPS
    echo "pass in proto tcp from any to any port 3000" >> /etc/pf.conf  # Allow Grafana
    echo "pass in proto tcp from any to any port 3306" >> /etc/pf.conf  # Allow MySQL

    # Load new rules and enable pf if not already enabled
    pfctl -f /etc/pf.conf
    pfctl -e                
    echo "FreeBSD firewall configured."
}

# Identify the OS and configure the firewall accordingly
case "$(uname -s)" in
    Linux)
        # Check if the system is Debian/Ubuntu or Rocky Linux
        if [[ -f /etc/debian_version ]]; then
            configure_ubuntu_debian_firewall
        elif [[ -f /etc/redhat-release ]]; then
            configure_rocky_firewall
        else
            echo "Unsupported Linux distribution."
            exit 1
        fi
        ;;
    FreeBSD)
        configure_freebsd_firewall
        ;;
    *)
        echo "Unsupported operating system."
        exit 1
        ;;
esac

echo "All firewalls configured successfully."