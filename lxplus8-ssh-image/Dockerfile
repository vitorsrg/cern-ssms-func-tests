################################################################################
# Image registry.cern.ch/vsantaro/lxplus8-ssh-image
################################################################################

FROM ubuntu:latest

ARG lxplus8_host

ENV lxplus8_host=$lxplus8_host

################################################################################
# Install SSH deps
################################################################################

RUN apt-get update -qq -y --allow-insecure-repositories
RUN apt-get install -qq -y \
    openssh-client \
    openssh-server \
    krb5-user

################################################################################
# Configure ssh
################################################################################

RUN mkdir -p /root/.ssh
RUN ssh-keyscan $lxplus8_host > /root/.ssh/known_hosts

COPY /.ssh/config /root/.ssh/config
COPY /keytab.krb /root/keytab.krb
COPY /krb5.conf /etc/krb5.conf

RUN chmod 0700 /root/.ssh
RUN chmod 600 /etc/krb5.conf

RUN kinit -f -kt /root/keytab.krb "vsantaro@CERN.CH"

################################################################################
# Entrypoint
################################################################################

CMD [ "/sbin/init" ]
