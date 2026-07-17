# immagine base per il container
FROM rockylinux:9

# uso di bash come shell
SHELL ["/bin/bash", "-c"]

# installazione pip, ansible-core e pulizia della cache.
RUN dnf install -y python3-pip && \
    dnf clean all && \
    pip3 install --no-cache-dir ansible-core

# creazione utente con la sua home
RUN useradd -m -u 1000 an-vault

# uso di an-vault come utente
USER an-vault

# impostazione della cartella di lavoro 
WORKDIR /home/an-vault/vault/

# copia dei file necessari per l'esecuzione del playbook
COPY --chown=an-vault:an-vault ./ansible.cfg ./
COPY --chown=an-vault:an-vault ./play.yml ./
COPY --chown=an-vault:an-vault ./id.yml ./

# cifratura
RUN echo "V4ul7" > pass.txt && \
    ansible-vault encrypt --vault-id pass.txt id.yml && \
    rm pass.txt
