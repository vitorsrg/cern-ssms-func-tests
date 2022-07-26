#!/usr/bin/env bash


set -e

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"


manage::main () {
    case $1 in
    "setup_ssh" )
        set -v
        printf "lxplus8s16.cern.ch" > lxplus8_host.txt

        kdestroy -A
        rm -rf ./keytab.krb
        read -s -p "Password: " cern_password
        printf "\n"
        ktutil \
            -k ./keytab.krb \
            add \
                -p "vsantaro@CERN.CH" \
                -e arcfour-hmac-md5 \
                --password=$cern_password \
                -V 3 \
                --no-salt
        kinit --afslog -f -kt ./keytab.krb "vsantaro@CERN.CH"
        klist -Af

    ;;
    "sync_down" )
        rsync \
            -aczP --delete --force --chmod=777 \
            "vsantaro@$(cat lxplus8_host.txt):~/" \
            "./lxplus8_home/"
    ;;
    "mount" )
        mkdir -p "./lxplus8_home/"
        sshfs "vsantaro@$(cat lxplus8_host.txt):./" "./lxplus8_home/"
    ;;
    "unmount" )
        umount -f "./lxplus8_home/"
    ;;
    "remount" )
        umount -f "./lxplus8_home/" || true
        mkdir -p "./lxplus8_home/"
        sshfs "vsantaro@$(cat lxplus8_host.txt):./" "./lxplus8_home/"
    ;;
    "docker_build" )
        cp -rf ./keytab.krb ./dispatch-check-eos/keytab.krb
        docker build \
            -t registry.cern.ch/vsantaro/func-tests \
            --build-arg lxplus8_host="$(cat lxplus8_host.txt)" \
            --squash \
            ./dispatch-check-eos
        cat ./harbor_secret.txt \
        | docker login \
            registry.cern.ch \
            --username vsantaro \
            --password-stdin
        docker push registry.cern.ch/vsantaro/func-tests
    ;;
    esac
}

manage::main $1
