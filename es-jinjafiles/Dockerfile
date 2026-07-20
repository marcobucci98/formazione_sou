FROM rockylinux:9

# uso di bash come shell
SHELL ["/bin/bash", "-c"]

# installazione di pip, pulizia della cache, e installazione di Ansible tramite pip
 RUN dnf install -y python3-pip && \
     dnf clean all && \
     pip3 install ansible-core

# imposta l'area di lavoro 
WORKDIR /root/es-jinjafiles/

# copia dei file necessari 
COPY ./ansible.cfg .
COPY ./user_settings.yml .
COPY ./whitelist.yml .