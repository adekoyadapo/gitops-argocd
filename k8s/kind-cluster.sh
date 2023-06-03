#!/bin/bash
printf "\033c"
if ! which kind;
then
    echo	-e "\033[31mERROR:\033[0m kind not found\nPlease install kind - https://kind.sigs.k8s.io/ and try again...!!!"
    exit 1
else
    echo
    echo -e "\033[32mCreating Cluster with 3 nodes...\033[0m\n"
    if [[ $(kind get clusters) != *argocd* ]] ;
    then
        kind create cluster --config cluster.yaml
        sleep 10
        echo
        echo -e "\033[32mDeploying Nginx Ingress...\033[0m\n"
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
        kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
        echo
        echo -e "\033[32mDeploying Metric Server...\033[0m\n"
        kubectl apply -f components.yaml
        kubectl wait --namespace kube-system \
        --for=condition=Ready pods \
        --selector=k8s-app=metrics-server \
        --timeout=300s
        echo
    else
        echo
        echo -e "\033[31mCluster already exists, delete it and try recreating again...\n"
    fi
fi
