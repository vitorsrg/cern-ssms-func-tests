################################################################################
# Image registry.cern.ch/vsantaro/func-tests
################################################################################

FROM ubuntu:latest

SHELL [
    "/bin/bash",
    "-c",
]

################################################################################
# Install SSH deps
################################################################################

RUN apt-get update -qq -y \
    --allow-insecure-repositories

################################################################################
# Install openstack
################################################################################

RUN apt-get install -qq -y \
    curl \
    gcc
RUN curl \
    -L -O \
    "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
RUN bash Mambaforge-$(uname)-$(uname -m).sh -b
RUN /root/mambaforge/bin/conda create -y -p /root/.conda 'python==3.10.0'
ENV PATH="/root/.conda/bin/:$PATH"

RUN pip install \
    "python-openstackclient==5.2.0" \
    "python-magnumclient==3.0.1" \
    --ignore-installed

################################################################################
# Install kubectl
################################################################################

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

################################################################################
# Copy sources
################################################################################

COPY /src /root/src

################################################################################
# Entrypoint
################################################################################

CMD [
    "/sbin/init",
]
