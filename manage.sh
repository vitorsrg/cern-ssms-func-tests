#!/usr/bin/env bash


set -e

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

manage::main () {
    case $1 in
    "setup_ssh" )
        set -v
        printf "lxplus8s16.cern.ch" > lxplus8_host.txt

        # ktutil -k ./keytab.krb add -p "vsantaro@CERN.CH" -e aes256-cts-hmac-sha1-96 -V 1 --no-salt
        # ktutil
        # add_entry -password -p "vsantaro@CERN.CH" -k 1 -e aes256-cts-hmac-sha1-96
        # add_entry -password -p "vsantaro@CERN.CH" -k 1 -e arcfour-hmac
        # write_kt keytab.krb
        # exit
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
        # kinit --afslog -f -kt ./keytab.krb -S "host/$(cat lxplus8_host.txt)" "vsantaro@CERN.CH"
        klist -Af
        # kinit -k -t ./keytab.krb -f -S "host/$(cat lxplus8_host.txt)" "vsantaro@CERN.CH"
        # kinit -k -t ./keytab.krb -f -S "host/lxplus8s16.cern.ch" "vsantaro@CERN.CH"

        # ktutil -k ./keytab.krb add -p "vsantaro@CERN.CH" -e aes256-cts -V 1 --no-salt
        # ktutil -k ./keytab.krb add -p "vsantaro@CERN.CH" -e arcfour-hmac-md5 -V 1 --no-salt
        # kinit -t ./keytab.krb -f "vsantaro@CERN.CH"
        # kinit -t ./keytab.krb -f -S "host/$(cat lxplus8_host.txt)" "vsantaro@CERN.CH"
        # kinit -S "host/$(cat lxplus8_host.txt)" "vsantaro@CERN.CH"
        # ssh-copy-id "vsantaro@$(cat lxplus8_host.txt)"
        # ssh-copy-id -i ~/.ssh/id_rsa_cern.pub "vsantaro@$(cat lxplus8_host.txt)"

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
