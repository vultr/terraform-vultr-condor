#!/usr/bin/env bash
set -euxo posix

SELF="/tmp/condor-init.sh"

KUBEADM_INIT_CONF="/tmp/kubeadm-init.conf"

MANIFEST_VULTR_API_KEY="/tmp/vultr-api-key.yml"
MANIFEST_VULTR_CCM="https://raw.githubusercontent.com/vultr/vultr-cloud-controller-manager/v${ VULTR_CCM_VERSION }/docs/releases/v${ VULTR_CCM_VERSION }.yml"
MANIFEST_VULTR_CSI="https://raw.githubusercontent.com/vultr/vultr-csi/v${ VULTR_CSI_VERSION }/docs/releases/v${ VULTR_CSI_VERSION }.yml"
MANIFEST_KUBE_FLANNEL="https://raw.githubusercontent.com/coreos/flannel/v${ KUBE_FLANNEL_VERSION}/Documentation/kube-flannel.yml"

FILES_TO_CLEAN="$KUBEADM_INIT_CONF $MANIFEST_VULTR_API_KEY $SELF"

cluster_init(){
    kubeadm init --config=$KUBEADM_INIT_CONF
    mkdir -p ~/.kube
    cp /etc/kubernetes/admin.conf ~/.kube/config
}

install_cni(){
    kubectl apply -f $MANIFEST_KUBE_FLANNEL
}

install_vultr(){
    kubectl apply -f $MANIFEST_VULTR_API_KEY
    kubectl apply -f $MANIFEST_VULTR_CCM
    kubectl apply -f $MANIFEST_VULTR_CSI
}

clean(){
    rm -f $FILES_TO_CLEAN
}

main(){
    cluster_init
    install_cni
    install_vultr
    clean
}

main
