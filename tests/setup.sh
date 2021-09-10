#!/usr/bin/env bats

load "./lib/helper"

@test "[SETUP] Deploy Permission manager Requirements" {
    info
    deploy(){
        kubectl delete namespace permission-manager

        kubectl create namespace permission-manager

        cat tests/manifests/permission-manager-secret.yml | envsubst | kubectl apply -f -

        kubectl apply -f deployments/kubernetes/seeds/crd.yml

        kubectl apply -f deployments/kubernetes/seeds/seed.yml

    }

    run deploy
    [ "$status" -eq 0 ]

}

@test "DEBUG SECRETS" {
    deploy(){
        cat tests/manifests/permission-manager-secret.yml | envsubst | kubectl apply -f -
    }
    run deploy
    echo "$output" >&3
    [ "$status" -eq 0 ]
}

@test "[SETUP] Build and Deploy Permission manager. It may take some time." {
    info

    deploy(){
      # we build the permission image from the current data and run the tests against it
      make deploy
    }

    run deploy
    echo "$output" >&3
    [ "$status" -eq 0 ]

}

@test "[SETUP] DEBUG" {
    info
    kubectl get all >&3
    kubectl get deploy -o yaml -n permission-manager >&3
    kubectl get secrets -n permission-manager >&3
    kubectl get pods -o wide -n permission-manager >&3
    kubectl describe pod -n permission-manager >&3
}
