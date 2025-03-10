#!/bin/bash
set -e  # Exit on error

# Update system
sudo yum update -y

# Install EPEL & Remi repositories
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm

# Install essential tools
sudo yum install -y wget vim python3 telnet htop git mysql net-tools chrony

# Start and enable Chrony for time synchronization
sudo systemctl enable --now chronyd

# Install EC2 Instance Connect (optional)
mkdir -p /tmp/ec2-instance-connect
curl -o /tmp/ec2-instance-connect/ec2-instance-connect.rpm \
     https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect.rpm
curl -o /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm \
     https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect-selinux.noarch.rpm
sudo yum install -y /tmp/ec2-instance-connect/ec2-instance-connect.rpm \
                     /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm

# Clean up temporary files
rm -rf /tmp/ec2-instance-connect

# Set SELinux permissions for WordPress and EFS
sudo setsebool -P httpd_can_network_connect=1
sudo setsebool -P httpd_can_network_connect_db=1
sudo setsebool -P httpd_execmem=1
sudo setsebool -P httpd_use_nfs=1

# Install Amazon EFS Utils
rm -rf efs-utils  # Remove old directory if it exists
git clone https://github.com/aws/efs-utils
cd efs-utils

# Install dependencies
sudo yum install -y make rpm-build openssl-devel cargo

# Build and install Amazon EFS Utils
make rpm
sudo yum install -y ./build/amazon-efs-utils*rpm

# Cleanup after installation
cd ..
rm -rf efs-utils

echo "✅ WordPress server setup completed successfully."
