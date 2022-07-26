FROM ubuntu:latest

ARG lxplus8_host

ENV lxplus8_host=$lxplus8_host

# Install SSH deps
RUN apt-get update -qq -y --allow-insecure-repositories
RUN apt-get install -qq -y \
    openssh-client \
    openssh-server \
    krb5-user

# Authorize SSH Host
RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
RUN ssh-keyscan $lxplus8_host > /root/.ssh/known_hosts
COPY /.ssh/config \
    /root/.ssh/config

# Setup kerberos auth
COPY /keytab.krb \
    /root/keytab.krb
COPY /krb5.conf \
    /etc/krb5.conf
RUN chmod 600 /etc/krb5.conf
# COPY /.ssh/id_rsa_cern \
#     /root/.ssh/id_rsa_cern
# COPY /.ssh/id_rsa_cern.pub \
#     /root/.ssh/id_rsa_cern.pub
# RUN chmod 600 /root/.ssh/id_rsa_cern
# RUN chmod 600 /root/.ssh/id_rsa_cern.pub
RUN kinit -f -kt /root/keytab.krb "vsantaro@CERN.CH"
# RUN kinit -k -t ./keytab.krb -f -S "host/$lxplus8_host"  "vsantaro@CERN.CH"

# RUN ssh \
#     -T -K -v \
#     "vsantaro@$lxplus8_host" \
#     "ls -l"

CMD [ "/sbin/init" ]
