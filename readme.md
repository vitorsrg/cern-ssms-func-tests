

1. Setup python env

    ```sh
    conda create \
        -y -p ./.conda \
        'python==3.10.0' \
        --channel conda-forge
    emulate ksh -c "source activate ./.conda/"
    pip install \
        "keystoneauth1[kerberos]==4.0.0" \
        "python-openstackclient==5.2.0" \
        "python-magnumclient==3.0.1" \
        --ignore-installed
    ```

1. Setup ssh

    ```sh
    bash manage.sh setup_ssh
    ```

1.

```sh
./argo-linux-amd64 submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/continue-on-fail.yaml
./argo-linux-amd64 submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml

./argo-linux-amd64 submit -n argo --watch ./check-eos.yml

./argo-linux-amd64 submit -n argo --watch ./dispatch-check-eos.yml

watch -n5 openstack server show d2022-06-28-functional-tests

ssh -XYNT -L '2746:[::1]:2746' "vsantaro@$(cat lxplus8_host.txt)"

kubectl -n argo port-forward deployment/argo-server 2746:2746

export KUBECONFIG=/afs/cern.ch/user/v/vsantaro/config
export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"

openstack keypair create vsantaro-key-2022-07-14
openstack coe cluster list
openstack coe cluster create vsantaro-func-tests \
    --keypair vsantaro-key-2022-07-14 \
    --cluster-template kubernetes-1.22.9-1 \
    --node-count 4
watch -n 10 openstack coe cluster show vsantaro-func-tests --max-width 100
openstack coe cluster config vsantaro-func-tests --force
kubectl cluster-info

kubectl create ns argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/quick-start-postgres.yaml



sshfs "vsantaro@$lxplus8_host:/afs/cern.ch/user/v/vsantaro/" "./lxplus8_home/"
umount -f "./lxplus8_home/"

```

git clone \
    "https://oauth2:$(cat ./secrets/gitlab_token.txt)@gitlab.cern.ch/kubernetes/testing/functional.git" \
    --branch vitorsrg \
    --single-branch \
    --depth 1 \
    ./func-tests2
