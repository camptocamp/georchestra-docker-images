#!/bin/bash

set -e

# Install and configure openssh-server
apt update
apt install -y --no-install-recommends --no-install-suggests openssh-server

rm -f /etc/ssh/ssh_host_*_key*
mkdir /var/run/sshd /etc/ssh/ssh_host_keys
sed -i -e 's@#HostKey /etc/ssh/ssh_host@HostKey /etc/ssh/ssh_host_keys/ssh_host@g' /etc/ssh/sshd_config
echo "AllowUsers sftp" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.client
sed -i -e 's@^Subsystem sftp .*@Subsystem sftp internal-sftp@' /etc/ssh/sshd_config.client
echo "Match User sftp" >> /etc/ssh/sshd_config.client
echo "    AllowTcpForwarding no" >> /etc/ssh/sshd_config.client
echo "    X11Forwarding no" >> /etc/ssh/sshd_config.client
echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config.client

# Add user tools

apt install -y --no-install-recommends --no-install-suggests \
    groff rsync vim-nox emacs-nox screen gdal-bin pktools wget curl file \
    python3-gdal nano git htop sudo tree less bash-completion zsh figlet colordiff unzip zip \
    python3 dnsutils ldap-utils postgresql-common uuid-runtime

# configure postgresql apt repository (PGDG)
# see https://wiki.postgresql.org/wiki/Apt

YES=yes /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
apt install -y postgresql-client-16/bookworm-pgdg

# cleanup system
apt-get clean
rm -rf /var/lib/apt/lists/*

# add sudo group with all sudo permissions
echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo-group

# Configure ssh user
useradd -r -d /home/sftp --shell /bin/bash sftp
mkdir -p /home/sftp.skel/.ssh
chown -R sftp.sftp /home/sftp.skel
ln -s /mnt /home/sftp.skel/data
adduser sftp sudo
