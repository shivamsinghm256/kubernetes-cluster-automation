# Kubernetes Cluster Automation

This repository contains **end-to-end automation** for provisioning and configuring a Kubernetes cluster on AWS using **Terraform and Ansible**.

---

## Features

**Infrastructure Provisioning**: Terraform to create AWS EC2 instances for Kubernetes master and worker nodes.  
**Cluster Bootstrap**: Ansible to install Docker/containerd, `kubeadm`, and initialize the cluster.  
**Networking**: Automated installation of Flannel CNI for pod networking.  
**Node Join Automation**: Automatic generation and execution of `kubeadm join` for workers.  
**Idempotent and Modular**: Can re-run safely for upgrades or changes.

---

## Project Structure

```
terraform/      # Terraform files for AWS infra provisioning
ansible/        # Ansible playbooks for Kubernetes setup
inventory/      # Ansible inventory files
scripts/        # Helper scripts (optional)
```

---

## Requirements

- Terraform
- Ansible
- AWS CLI configured
- SSH access to instances

---

## Usage

### 1️⃣ Provision Infrastructure
```
bash
cd terraform
terraform init
terraform apply
```
### 2️⃣ Run Ansible Playbooks

cd ansible
ansible-playbook -i inventory/hosts site.yml

---

## Verification

After successful deployment:
```
sudo kubectl get nodes
sudo kubectl get pods -A
```
