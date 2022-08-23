#!/usr/bin/env bash


# set -e

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
set -x
set +x

manage::main () {
    case $1 in
    "setup_creds" )
        manage::setup_creds
    ;;
    "sync_down" )
        rsync \
            -aczP --delete --force --chmod=777 \
            "vsantaro@$(cat lxplus8_host.txt):~/" \
            "./lxplus8_home/"
    ;;
    "remount" )
        manage::remount
    ;;
    "build_docker" )
        manage::build_docker
    ;;
    "dispatch_argo" )
        manage::dispatch_argo
    ;;
    "serve_argo" )
        manage::serve_argo
    ;;
    * )
        printf "Unknown command\n"
        exit -1
    ;;
    esac
}

manage::setup_creds () {
    set -x

    source "$(pwd)/src/script/util.sh"

    kdestroy -A
    rm -rf ./secrets/cern_keytab.krb
    # read -s -p "Password: " cern_password
    # printf "\n"
    # set +x
    # ktutil \
    #     -k ./secrets/cern_keytab.krb \
    #     add \
    #         -p "vsantaro@CERN.CH" \
    #         -e arcfour-hmac-md5 \
    #         --password=$cern_password \
    #         -V 3 \
    #         --no-salt
    # set -x
    # kinit \
    #     --afslog -f -kt \
    #     ./secrets/cern_keytab.krb \
    #     "vsantaro@CERN.CH"
    klist -Af

    ssh \
        "vsantaro@lxplus8.cern.ch" \
        "hostname -I" \
        | awk '{print $1}' \
        | xargs -I {} host {} \
        | perl -0777 -e 'print <> =~ s/b/d/gr' \
        > ./secrets/lxplus8_host.txt

    ssh \
        "vsantaro@$(cat lxplus8_host.txt)" \
        <(
            util::dedent '
                export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"
                openstack token issue -f json
                ' \
        ) \
        | jq -r '.id' \
        > ./secrets/openstack_token.txt

    open https://registry.cern.ch/

    source \
        ./src/script/openstack/setup_token.sh \
        $(cat ./secrets/os_token.txt)

    openstack coe cluster config \
        vsantaro-func-tests \
        --dir "/tmp/func-tests/" \
        --force
    mv \
        "/tmp/func-tests/config" \
        "$(pwd)/secrets/kubeconfig.yml"
    export KUBECONFIG="$(pwd)/secrets/kubeconfig.yml"
}

manage::remount () {
    set -x
    umount -f "./lxplus8_home/" || true
    mkdir -p "./lxplus8_home/"
    sshfs "vsantaro@$(cat lxplus8_host.txt):./" "./lxplus8_home/"
}

manage::build_docker () {
    set -x

    docker build \
        -t registry.cern.ch/vsantaro/func-tests \
        --squash \
        ./docker_image
    cat ./secrets/harbor_token.txt \
        | docker login \
            registry.cern.ch \
            --username vsantaro \
            --password-stdin
    docker push registry.cern.ch/vsantaro/func-tests
}

manage::dispatch_argo () {
    set -x

    export KUBECONFIG="$(pwd)/secrets/kubeconfig.yml"

    # kubectl get namespace
    ./argo.bin \
        submit -n argo ./src/workflow/sample.yml \
        -p "openstack_token=$(cat ./secrets/os_token.txt)" \
        -p "gitlab_token=$(cat ./secrets/gitlab_token.txt)" \
        -p "test_name=k8s-eos"
}

manage::serve_argo () {
    set -x

    export KUBECONFIG="$(pwd)/secrets/kubeconfig.yml"

    kubectl -n argo port-forward deployment/argo-server 2746:2746
}

manage::dispatch_job () {
    set -x

    source_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    export KUBECONFIG="$source_dir/kubeconfig.yml"

    kubectl delete job check-eos || true
    kubectl apply -f ./lxplus8-ssh-image/src/k8s-eos/job.yml
    # kubectl wait --for=condition=complete job/check-eos --timeout=-1s
    # sleep 30
    # kubectl get job check-eos -o json | jq '.status'

    while true; do
        sleep 10
        active=$(kubectl get job check-eos -o json | jq -r '.status | has("active")')
        succeeded=$(kubectl get job check-eos -o json | jq -r '.status | has("succeeded")')

        if [ "$active" = "true" ]; then
            printf "Waiting job to finish.\n"
            continue
        elif [ "$succeeded" = "true" ]; then
            printf "Job succeeded.\n"
            break
        else
            printf "Job failed.\n"
            exit -1
        fi
    done
    sleep 30
    # kubectl logs job/check-eos
    kubectl describe job/check-eos
    # kubectl explain jobs.status
    kubectl get job check-eos -o json | jq '.status'
    kubectl get job check-eos -o json | jq -r '.status.succeeded'

}

manage::main $1
