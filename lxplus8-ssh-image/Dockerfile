################################################################################
# Image registry.cern.ch/vsantaro/lxplus8-ssh-image
################################################################################

FROM ubuntu:latest

SHELL [
    "/bin/bash",
    "-c",
]

# ARG lxplus8_host

# ENV lxplus8_host=$lxplus8_host

################################################################################
# Install SSH deps
################################################################################

RUN apt-get update -qq -y \
    --allow-insecure-repositories

################################################################################
# Configure lxplus8 ssh
################################################################################

# RUN apt-get install -qq -y \
#     openssh-client \
#     openssh-server \
#     krb5-config \
#     krb5-user \
#     libkrb5-dev

# RUN mkdir -p /root/.ssh
# RUN ssh-keyscan $lxplus8_host > /root/.ssh/known_hosts

# COPY /.ssh/config /root/.ssh/config
# COPY /keytab.krb /root/keytab.krb
# COPY /krb5.conf /etc/krb5.conf

# RUN chmod 0700 /root/.ssh
# RUN chmod 600 /etc/krb5.conf

# RUN kinit -f -kt /root/keytab.krb "vsantaro@CERN.CH"

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
#     "keystoneauth1[kerberos]==4.0.0" \

# COPY /os_rc_krb.sh /root/os_rc_krb.sh
COPY /os_rc_token.sh /root/os_rc_token.sh
COPY /os_token.txt /root/os_token.txt

################################################################################
# Install kubectl
################################################################################

RUN curl \
    -fsSLo \
    /usr/share/keyrings/kubernetes-archive-keyring.gpg \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg
COPY /kubernetes.list /etc/apt/sources.list.d/kubernetes.list

################################################################################
# Install misc deps
################################################################################

RUN apt-get install -qq -y \
    jq
RUN apt-get update
RUN apt-get install -qq -y \
    kubectl

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
