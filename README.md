# UFW-audit
# 🔒 UFW Audit & Auto-Fix Script

A simple yet powerful Bash script that audits and applies security best practices to your Ubuntu firewall (UFW). Ideal for developers, sysadmins, or anyone managing Linux servers.

---

## 🚀 Features

- ✅ Detects if UFW is installed and prompts to install if missing
- ✅ Ensures UFW is enabled
- 🔍 Scans open ports and flags risky defaults (e.g., SSH on port 22, MySQL)
- 🛠️ Offers to close or change insecure ports
- ⚠️ Warns about IPv6 rules if not needed
- 📋 Generates a timestamped log file for compliance/reporting

---

## 🛠️ Requirements

- Ubuntu or Debian-based system
- `sudo` privileges

---

## 📦 Installation & Usage

```bash
wget https://raw.githubusercontent.com/yourusername/ufw-audit/main/ufw_audit.sh
chmod +x ufw_audit.sh
./ufw_audit.sh
```
## 📝 Example Output
```bash
[INFO] UFW is active.
[SECURITY] Port 22 (SSH default) is open!
[INFO] SSH is open on port 22.
Do you want to change SSH to port 2222? [y/N]:
[WARNING] IPv6 rules detected...
```
## 📎 Logs
Logs are saved to a timestamped file like:

ufw_audit_2025-06-04_21:12:00.log
## ❗ Notes
Changing the SSH port will require updating /etc/ssh/sshd_config and restarting the SSH daemon.

Always ensure you won’t get locked out before closing any ports.

## Troubleshoot 
🧹 Bonus: Check Script Syntax
You can quickly validate shell scripts using:
```bash
bash -n ufw_fixer.sh
```
