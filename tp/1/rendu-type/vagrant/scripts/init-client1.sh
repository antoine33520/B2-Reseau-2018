#!/bin/bash
# it4
# 20/02/2019
# Init script for client1.tp1.b2 VM 

# Install network-related packages
echo "Installing netork-related packages"
yum install -y tcpdump bind-utils nc traceroute

# Fill /etc/hosts file
echo "Filling /etc/hosts file"
hosts_file="127.0.0.1	client1.tp1.b2	client1
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.1.1 host.tp1.b2
10.1.1.2 client1.tp1.b2
10.1.1.3 client2.tp1.b2
10.1.2.1 host.tp1.b2
10.1.2.2 client1.tp1.b2"

echo "$hosts_file" > /etc/hosts

# Disable SELinux
echo "Disabling SELinux"
setenforce 0
sed -i 's/permissive/enforcing/g' /etc/selinux/config

# Be sure that firewalld is started
[[ $(systemctl is-active firewalld) != "active" ]] \
	&& echo "Starting Firewalld" \
	&& systemctl start firewalld

# Delete default route created by VirtualBox NAT interface"
echo "Delete default route created by VirtualBox NAT interface"
ip route del default
