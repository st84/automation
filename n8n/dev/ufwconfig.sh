ufw default deny incoming
ufw default allow outgoing
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow from YOUR_STATIC_IP/32 to any port 22 proto tcp
ufw enable
ufw status
