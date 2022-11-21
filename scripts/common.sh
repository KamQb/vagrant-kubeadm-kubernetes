#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

set -euxo pipefail

#### Variables Declaration

KUBERNETES_VERSION="1.25*"
OS_VERSION_NAME="jammy"

#### Prereqs

echo "Disabling swap"

# disable swap
sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true


#### Containerd

echo "Installing Containerd"

sudo apt-get update -y
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Finally install containerd
sudo apt-get update 
sudo apt-get install -y containerd

#Create a containerd configuration file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

#Set the cgroup driver for containerd to systemd which is required for the kubelet.
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

#Restart containerd with the new configuration
sudo systemctl restart containerd

echo "Finished installing Containerd"

#### Kubernetes packages

echo "Installing Kubernetes packages"

#Add Google's apt repository gpg key
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Kube apt packages
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Note: https://apt.kubernetes.io/ doesn't have definitions for newer releases

# Finally isntall kube components
sudo apt-get update -y
sudo apt-get install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"

# Dont update kube with normal apt updates
sudo apt-mark hold kubelet kubeadm kubectl containerd

# Run at startup
sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service

echo "Finished installing Kubernetes packages"

#### Others

# Usefull for working with json
sudo apt-get install -y jq

# # Set kube local IP to proper interface
# local_ip="$(ip --json a s | jq -r '.[] | if .ifname == "eth1" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
# sudo cat > /etc/default/kubelet << EOF
# KUBELET_EXTRA_ARGS=--node-ip=$local_ip
# EOF


