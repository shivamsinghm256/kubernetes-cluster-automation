[master]
${master_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/kube-cluster

[worker]
%{ for ip in worker_ips ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/kube-cluster
%{ endfor ~}