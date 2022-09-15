################################################################################
# Image registry.cern.ch/vsantaro/func-tests
################################################################################

FROM condaforge/miniforge3:4.13.0-1

SHELL ["/bin/bash", "-c"]

################################################################################
# Install SSH deps
################################################################################

RUN apt-get update -qq -y \
    --allow-insecure-repositories

################################################################################
# Install openstack
################################################################################

RUN pip install \
    "python-openstackclient==5.2.0" \
    "python-magnumclient==3.0.1"

################################################################################
# Install kubectl
################################################################################

RUN apt-get install -qq -y \
    curl
RUN curl \
    -fsSLo \
    /usr/share/keyrings/kubernetes-archive-keyring.gpg \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg
COPY /kubernetes.list /etc/apt/sources.list.d/kubernetes.list

RUN apt-get update
RUN apt-get install -qq -y \
    kubectl

################################################################################
# Install misc deps
################################################################################

RUN apt-get install -qq -y \
    jq

RUN pip install \
    "jinja2==3.1.2" \
    "yq==3.1.0"

################################################################################
# Entrypoint
################################################################################

CMD ["/sbin/init"]
