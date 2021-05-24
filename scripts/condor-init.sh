#!/usr/bin/env bash
set -euxo posix

SELF="/tmp/condor-init.sh"

KUBEADM_INIT_CONF="/tmp/kubeadm-init.conf"

FILES_TO_CLEAN="$KUBEADM_INIT_CONF $SELF"

cluster_init(){
    kubeadm init --config=$KUBEADM_INIT_CONF
    mkdir -p ~/.kube
    cp /etc/kubernetes/admin.conf ~/.kube/config
}

clean(){
    rm -f $FILES_TO_CLEAN
}

main(){
    cluster_init
    clean
}

main
