# immagine base per il container
FROM rockylinux:9

# uso di bash come shell
SHELL ["/bin/bash", "-c"]

# installazione di pip e pulizia della cache
RUN dnf install -y python3-pip && dnf clean all

# creazione utente 
# crea un utente chiamato "an-vault" con UID 1000 e la sua cartella home
RUN useradd -m -u 1000 an-vault

# installa Ansible tramite pip senza salvare la cache 
RUN pip3 install --no-cache-dir ansible-core

# imposta area di lavoro
WORKDIR /home/an-vault/vault/

# copia dei file necessari
COPY --chown=an-vault:an-vault ./ansible.cfg /home/an-vault/vault/
COPY --chown=an-vault:an-vault ./play.yml /home/an-vault/vault/
COPY --chown=an-vault:an-vault ./id.yml /home/an-vault/vault/

#  cifratura : viene scritta la password nel file "pass.txt"
#  viene poi cifrato il file id.yml
#  viene poi eliminato il file che contiene la password
#  viene assegnato il proprietario del file cifrato all'utente an-vault
#  vengono modificati i permessi per la lettura del file 
RUN echo "V4ul7" > pass.txt && \
    ansible-vault encrypt --vault-id pass.txt id.yml && \
    rm pass.txt && \
    chown an-vault:an-vault id.yml && \
    chmod 644 id.yml

# imposta l'utente, il container verrà utilizzato tramite l'utente an-vault 
USER an-vault
