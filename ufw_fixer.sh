#!/bin/bash

# Title: UFW Audit & Auto-Fix Script
# Author: mkcloudai
# Description: Audits current UFW firewall config, suggests and applies security best practices.

log_file="ufw_audit_$(date +%F_%T).log"
echo "[INFO] Logging to $log_file"

log() {
    echo -e "$1" | tee -a "$log_file"
}

ask_confirm() {
    read -p "$1 [y/N]: " -r
    [[ $REPLY =~ ^[Yy]$ ]]
}

log "\n--- UFW AUDIT STARTED ---\n"

# Step 1: Check UFW installed
if ! command -v ufw &>/dev/null; then
    log "[WARNING] UFW is not installed."
    if ask_confirm "Do you want to install UFW now?"; then
        sudo apt update && sudo apt install ufw -y
        log "[INFO] UFW installed."
    else
        log "[ERROR] UFW not installed. Exiting."
        exit 1
    fi
fi

# Step 2: Check UFW status
ufw_status=$(sudo ufw status | head -n 1)
if [[ "$ufw_status" == "Status: inactive" ]]; then
    log "[WARNING] UFW is installed but not enabled."
    if ask_confirm "Enable UFW now?"; then
        sudo ufw enable
        log "[INFO] UFW enabled."
    else
        log "[ERROR] UFW must be enabled for this audit. Exiting."
        exit 1
    fi
else
    log "[INFO] UFW is active."
fi

# Step 3: Show active rules
log "\n[INFO] Active UFW Rules:"
sudo ufw status numbered | tee -a "$log_file"

# Step 4: Scan and analyze open ports
log "\n[CHECK] Analyzing open ports..."
open_ports=$(sudo ufw status | awk '$2 == "ALLOW" {print $1}')

# Define risky ports
declare -A risky_ports=(
    [22]="SSH (default)"
    [23]="Telnet"
    [3306]="MySQL"
    [5432]="PostgreSQL"
    [21]="FTP"
)

for port in "${!risky_ports[@]}"; do
    if echo "$open_ports" | grep -q "^$port/tcp"; then
        log "[SECURITY] Port $port (${risky_ports[$port]}) is open!"
        if ask_confirm "Do you want to close port $port?"; then
            sudo ufw delete allow "$port"
            log "[FIXED] Closed port $port."
        fi
    fi
done

# Step 5: SSH port 22 custom suggestion (precise)
if sudo ufw status | grep -E '^[ ]*22/tcp[ ]+ALLOW'; then
    log "[INFO] SSH is open on port 22 (default)."
    if ask_confirm "Do you want to change SSH to port 2222 for better security?"; then
        sudo ufw allow 2222/tcp
        sudo ufw delete allow 22/tcp
        log "[INFO] Remember to update /etc/ssh/sshd_config and restart SSH:"
        log "       sudo nano /etc/ssh/sshd_config"
        log "       -> Change: Port 22 → Port 2222"
        log "       sudo systemctl restart ssh"
    fi
else
    log "[OK] SSH (port 22) is not explicitly open."
fi

# Step 6: IPv6 check
if sudo ufw status | grep -q "\(v6\)"; then
    log "[WARNING] IPv6 rules detected. If unused, consider blocking."
    if ask_confirm "Do you want to deny all IPv6 traffic?"; then
        sudo ufw deny in from ::/0
        log "[FIXED] IPv6 traffic denied."
    fi
fi

log "\n--- AUDIT COMPLETE ---"
log "[INFO] Review full log here: $log_file"
