
# Vagrantfile and Scripts to Automate Kubernetes Setup using Kubeadm [Practice Environment for CKA/CKAD and CKS Exams]

## Fork info

This is based both on [Devopscube cluster vagrant](https://devopscube.com/kubernetes-cluster-vagrant/) 
and 
[Pluralsight - Anthony Nocentino - Kubernetes Installation and Configuration Fundamentals ](https://www.pluralsight.com/courses/kubernetes-installation-configuration-fundamentals)

Kubernetes installed using kubeadm, with Containerd runtime. Ubuntu images updated to 22.04. Kubernetes version 1.25.4

## Documentation

Current k8s version for CKA, CKAD and CKS exam: 1.25

## Prerequisites

1. Working Vagrant setup
2. VMs are using 18GB of Ram and 10 vCPUs

## For MAC/Linux Users

Latest version of Virtualbox for Mac/Linux can cause issues because you have to create/edit the /etc/vbox/networks.conf file and add:
<pre>* 0.0.0.0/0 ::/0</pre>

or run below commands

```shell
sudo mkdir -p /etc/vbox/
echo "* 0.0.0.0/0 ::/0" | sudo tee -a /etc/vbox/networks.conf
```

So that the host only networks can be in any range, not just 192.168.56.0/21 as described here:
https://discuss.hashicorp.com/t/vagrant-2-2-18-osx-11-6-cannot-create-private-network/30984/23

## Usage/Examples

To provision the cluster, execute the following commands.

```shell
git clone https://github.com/scriptcamp/vagrant-kubeadm-kubernetes.git
cd vagrant-kubeadm-kubernetes
vagrant up
```

## Set Kubeconfig file variable

```shell
cd vagrant-kubeadm-kubernetes
cd configs
export KUBECONFIG=$(pwd)/config
```

or you can copy the config file to .kube directory.

```shell
cp config ~/.kube/
```

## Kubernetes Dashboard URL

```shell
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=kubernetes-dashboard
```

## Kubernetes login token

Vagrant up will create the admin user token and saves in the configs directory.

```shell
cd vagrant-kubeadm-kubernetes
cd configs
cat token
```

## To shutdown the cluster,

```shell
vagrant halt
```

## To restart the cluster,

```shell
vagrant up
```

## To destroy the cluster,

```shell
vagrant destroy -f
```

