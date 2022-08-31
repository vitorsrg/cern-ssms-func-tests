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

# RUN apt-get install -qq -y \
#     gcc

# RUN conda create -y -p /root/.conda 'python==3.10.0'
# ENV PATH="/root/.conda/bin/:$PATH"

RUN pip install \
    "python-openstackclient==5.2.0" \
    "python-magnumclient==3.0.1"

# RUN apt-get autoremove -qq -y \
#     --purge \
#     gcc

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
    "yq==3.1.0"

################################################################################
# Entrypoint
################################################################################

CMD ["/sbin/init"]
