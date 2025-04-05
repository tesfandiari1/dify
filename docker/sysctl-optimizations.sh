#!/bin/bash
# System-level optimizations for Dify on EC2 c6a.xlarge
# Run this as root (with sudo) before starting Docker services

# Increase the maximum number of open files
echo "fs.file-max = 512000" >> /etc/sysctl.conf

# Optimize network settings
echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 65536" >> /etc/sysctl.conf
echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf
echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 8096" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf

# Virtual memory optimizations
echo "vm.swappiness = 10" >> /etc/sysctl.conf
echo "vm.dirty_ratio = 40" >> /etc/sysctl.conf
echo "vm.dirty_background_ratio = 10" >> /etc/sysctl.conf

# Apply all changes
sysctl -p

# Set ulimits for the current session
ulimit -n 512000

# Add ulimit setting to /etc/security/limits.conf for persistence across reboots
cat <<EOF >> /etc/security/limits.conf
*       soft    nofile  512000
*       hard    nofile  512000
root    soft    nofile  512000
root    hard    nofile  512000
EOF

echo "System optimizations applied successfully!" 