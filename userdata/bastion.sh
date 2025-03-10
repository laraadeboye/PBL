# update yum repo
sudo yum update -y

# install epel release
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# install remi repo
sudo yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm

# install necessary tools
sudo yum install wget vim python3 telnet htop git mysql net-tools chrony -y

# Start chronyd
sudo systemctl start chronyd
sudo systemctl enable chronyd
sudo systemctl status chronyd

# install instance connect (optional)
mkdir /tmp/ec2-instance-connect
curl https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect.rpm -o /tmp/ec2-instance-connect/ec2-instance-connect.rpm
curl https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect-selinux.noarch.rpm -o /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm
sudo yum install -y /tmp/ec2-instance-connect/ec2-instance-connect.rpm /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm

