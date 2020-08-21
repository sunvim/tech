#!/bin/sh

apt install -y gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add

tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

apt update

apt-mark unhold  kubelet=1.15.9-00 kubeadm=1.15.9-00 kubectl=1.15.9-00

apt install -y kubelet kubeadm kubectl
rm -rf /usr/local/bin/kubectl
apt remove -y kubelet kubeadm kubectl

apt-get install -y kubelet=1.15.9-00 kubeadm=1.15.9-00 kubectl=1.15.9-00 docker.io

apt-mark hold  kubelet=1.15.9-00 kubeadm=1.15.9-00 kubectl=1.15.9-00

tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf <<-'EOF'

# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
#Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --fail-swap-on=false"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS \$KUBELET_CGROUP_ARGS

EOF

apt install -y ipvsadm conntrack ipset ceph-common

for v in bridge br_netfilter ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo ip_vs_nq ip_vs_sed ip_vs_ftp; do
    /sbin/modprobe $v
done