#!/bin/bash

set -e  # Exit on error

# Update yum repository
sudo yum update -y

# Install EPEL release
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Install DNF utilities before Remi repository
sudo yum install -y dnf-utils
sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-9.rpm

# Install necessary tools
sudo yum install -y wget vim python3 telnet htop git mysql net-tools chrony nginx

# Start and enable Chrony (for time synchronization)
sudo systemctl enable --now chronyd

# Install Amazon EC2 Instance Connect (optional)
mkdir /tmp/ec2-instance-connect
curl -o /tmp/ec2-instance-connect/ec2-instance-connect.rpm \
    https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect.rpm
curl -o /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm \
    https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect-selinux.noarch.rpm
sudo yum install -y /tmp/ec2-instance-connect/ec2-instance-connect.rpm \
                     /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm

# Set SELinux booleans for Nginx to allow necessary network connections
sudo setsebool -P httpd_can_network_connect=1
sudo setsebool -P httpd_can_network_connect_db=1
sudo setsebool -P httpd_execmem=1
sudo setsebool -P httpd_use_nfs=1

# Start and enable Nginx
sudo systemctl enable --now nginx

# Clean up temporary files
rm -rf /tmp/ec2-instance-connect

echo "✅ Nginx installation and configuration complete!"
