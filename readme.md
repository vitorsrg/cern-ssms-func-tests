

## Decision record

### Bash library structure and documentation

1. Docopt command-line interface [website](http://docopt.org/).
1. Google bash style guide [website](https://google.github.io/styleguide/shellguide.html).

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

https://argoproj.github.io/argo-workflows/workflow-concepts/
https://gitlab.cern.ch/kubernetes/testing/functional

1. Setup ssh

    ```sh
    bash manage.sh setup_ssh
    ```

1.

ksource "./src/openstack/setup_k8s.sh" \
    "vsantaro-func-tests--test" \
    "./secrets/kubeconfig2.yml"

```sh

watch -n5 openstack server show d2022-06-28-functional-tests




openstack keypair create vsantaro-key-2022-07-14
openstack coe cluster list
openstack coe cluster create vsantaro-func-tests \
    --keypair vsantaro-key-2022-07-14 \
    --cluster-template kubernetes-1.22.9-1 \
    --node-count 4
watch \
    -n 10 \
    openstack coe cluster show \
        vsantaro-func-tests \
        --max-width 100
openstack coe cluster config vsantaro-func-tests --force
kubectl cluster-info

kubectl apply \
    -f https://raw.githubusercontent.com/argoproj/argo-workflows/v3.3.9/manifests/quick-start-postgres.yaml

kubectl create \
    -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.0/bundle.yaml

sshfs "vsantaro@$lxplus8_host:/afs/cern.ch/user/v/vsantaro/" "./lxplus8_home/"
umount -f "./lxplus8_home/"

```

git clone \
    "https://oauth2:$(cat ./secrets/gitlab_token.txt)@gitlab.cern.ch/kubernetes/testing/functional.git" \
    --branch vitorsrg \
    --single-branch \
    --depth 1 \
    ./func-tests2
