# ANSIBLE VAULT

Implementazione del'esercizio **Ansible Vault**. 

L'esercizio consiste nell'eseguire un playbook tramite Ansible, che richiami e stampi delle variabili contenute in un file `.yml` protetto da Ansible Vault tramite password, che deve essere richiesta poi all'utente prima dell'esecuzione del playbook.
Il tutto viene gestito all'interno dei container con l'utilizzo di Podman.

## SVILUPPO

L'esercizio è stato sviluppato come segue: 

### DOCKERFILE

Il setup viene predisposto tramite un Dockerfile: 

Imposta l'immagine del container : 
`FROM rockylinux:9`

Imposta l'uso di bash come shell : 
`SHELL ["/bin/bash", "-c"]`

Installazione di pip e pulizia della cache : 
`RUN dnf install -y python3-pip && dnf clean all`

Crea un utente chiamato "an-vault" con UID 1000 e la sua cartella home : 
`RUN useradd -m -u 1000 an-vault`

Installa Ansible tramite pip senza salvare la cache : 
`RUN pip3 install --no-cache-dir ansible-core`

Imposta area di lavoro : 
`WORKDIR /home/an-vault/vault/`

Copia dei file necessari : 

`COPY --chown=an-vault:an-vault ./ansible.cfg /home/an-vault/vault/`

`COPY --chown=an-vault:an-vault ./play.yml /home/an-vault/vault/`

`COPY --chown=an-vault:an-vault ./id.yml /home/an-vault/vault/`

Cifratura del file : 

`RUN echo "V4ul7" > pass.txt && \`

   ` ansible-vault encrypt --vault-id pass.txt id.yml && \`

   ` rm pass.txt && \`

   ` chown an-vault:an-vault id.yml && \`

   ` chmod 644 id.yml`

Imposta l'utente, il container verrà utilizzato tramite l'utente `an-vault` : 

`USER an-vault`


### id.yml 
L'elenco delle variabili che vengono cifrate: 

`
nome: paolo
cognome: rossi
età: 22
città: roma
`
### play.yml

Il playbook che verrà eseguito, e che ci permetterà di visualizzare il contenuto delle variabili: 

Titolo: `- name: Variabili cifrate con Ansible Vault`
  
Specifica su quali macchine eseguire il playbook.
  `hosts: localhost`

Esegue i comandi direttamente sulla macchina locale
  `connection: local`
  
Vengono caricate le variabili definite nel file cifrato "id.yml" : 
  `vars_files:
    - id.yml`

Azioni da eseguire : `tasks:`

Titolo: `- name: Mostra il nome`

Modulo per la stampa dei messaggi : `ansible.builtin.debug:`

Stampa il testo e poi viene letta la variabile : `msg: "Il nome è: {{ nome }}"`

Titolo : `- name: Mostra il cognome`

Modulo per la stampa dei messaggi : `ansible.builtin.debug:`

Stampa il testo e poi viene letta la variabile : `msg: "Il cognome è: {{ cognome }}"`
      
Titolo : `- name: Mostra l'età`

Modulo per la stampa dei messaggi : `ansible.builtin.debug:`

Stampa il testo e poi viene letta la variabile : `msg: "L'età è: {{ età }}"`

Titolo : `- name: Mostra la città di nascita`

Modulo per la stampa dei messaggi : `ansible.builtin.debug:`

Stampa il testo e poi viene letta la variabile : `msg: "La città di nascita è: {{ città }}"` 

### ansible.cfg

Il file `ansible.cfg` è il file di configurazione iniziale di Ansible.

Questo tipo di setup ha il compito di disattivare i vari warning che si presentano.

`[defaults]`

`localhost_warning = False`

`inventory_unparsed_warning = False`

`display_skipped_hosts = False` 

Questi ultimi parametri hanno il compito di utilizzare l'utente `an-vault`, e di impedire che venga richiesta la password dell'utente root : 

`[privilege_escalation]`

`become = False`

`become_ask_pass = False`

## REQUISITI PER L'AVVIO

E' necessario avere PODMAN o DOCKER installato.

## AVVIO

1. Scarica la cartella sul computer.
2. Aprire il terminale e posizionati nella directory del progetto.
3. Lanciare il comando `podman build -t nome_immagine . `
- L'opzione `-t`, permette di taggare l'immagine appena buildata.
- Il `.` alla fine del comando, per mette di prendere il Dockerfile che abbiamo nella cartella locale per creare l'immagine.
4. Una volta completato il setup dell'immagine lanciare il comando `podman run -it --name nome_container nome_immagine `
5. Una volta lanciato quest'ultimo comando, ci troveremo all'interno del container, nell'area di lavoro creata nel Dockerfile, e troveremo tutti i file copiati direttamente nella cartella di lavoro del container, ora dovremmo lanciare il comando `ansible-playbook play.yml --ask-vault-password`,per eseguire il playbook, e ci chiederà di inserire la password.
- L'opzione `--ask-vault-password`, fa in modo di chiedere la password per accedere al Vault.
6. La password da inserire è `V4ul7`.
7. Una volta inserita ci restituirà i valori delle variabili incluse nel file `id.yml`
