#!/usr/bin/env bash
set -euxo posix

SELF="/tmp/condor-init.sh"

KUBEADM_INIT_CONF="/tmp/kubeadm-init.conf"

MANIFEST_VULTR_API_KEY="/tmp/vultr-api-key.yml"
MANIFEST_VULTR_CCM="/tmp/vultr-ccm.yml"
MANIFEST_KUBE_FLANNEL="/tmp/kube-flannel.yml"

FILES_TO_CLEAN="$KUBEADM_INIT_CONF $MANIFEST_KUBE_FLANNEL $MANIFEST_VULTR_API_KEY $MANIFEST_VULTR_CCM $SELF"

cluster_init(){
    kubeadm init --config=$KUBEADM_INIT_CONF
    mkdir -p ~/.kube
    cp /etc/kubernetes/admin.conf ~/.kube/config
}

install_cni(){
    kubectl apply -f $MANIFEST_KUBE_FLANNEL
}

install_ccm(){
    kubectl apply -f $MANIFEST_VULTR_API_KEY
    kubectl apply -f $MANIFEST_VULTR_CCM
}

clean(){
    rm -f $FILES_TO_CLEAN
}

main(){
    cluster_init
    install_cni
    install_ccm
    #clean
}

main
