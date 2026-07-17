# Installazione pacchetti tramite Playbook

Implementazione del'esercizio **Installazione pacchetti tramite Playbook**. 

L'esercizio consiste nell'eseguire un playbook tramite Ansible, che installi e disinstalli pacchetti in base a due liste contenute in un dizionario.
Il tutto viene gestito all'interno dei container con l'utilizzo di Podman.

## SVILUPPO

L'esercizio è stato sviluppato come segue: 

### DOCKERFILE

Il setup viene predisposto tramite un Dockerfile: 

Immagine base per il container : 

`FROM rockylinux:9`

Uso di bash come shell : 

`SHELL ["/bin/bash", "-c"]`

Installazione di pip, pulizia della cache, e installazione di Ansible tramite pip : 

`RUN dnf install -y python3-pip && \`

`dnf clean all && \`

`pip3 install ansible-core`

Imposta l'area di lavoro : 

`WORKDIR /root/liste-dizionari/`

Copia dei file necessari nell'area di lavoro :

`COPY ./ansible.cfg .`

`COPY ./play.yml .`
`
### play.yml

Il playbook che verrà eseguito : 

Titolo : `- name: Gestione pacchetti # nome del Play`

Specifica su quali macchine eseguire il playbook : `hosts: localhost`

Esegue i comandi direttamente sulla macchina locale : `connection: local`

Variabili : `vars:`

Dizionario che contiene i pacchetti e i loro stati : `software:` 

La lista dei pacchetti che vogliamo installare : `present:`

Elementi : `...`
       
La lista dei pacchetti che vogliamo disinstallare : `absent:`

Elementi : `...`

Azioni da eseguire : `tasks:`

Nome della task : `- name: Installazione dei pacchetti`

Modulo per la gestione dei pacchetti : `ansible.builtin.package:`

Verranno passati i valori della lista dei pacchetti da installare : `name: "{{ item }}"`

Lo stato che vogliamo ottenere : `state: present`

Il ciclo che scorre la lista : `loop: "{{ software.present }}"`

Esegue le azioni solo se la lista è definita : `when: software.present is defined`

Nome della task : `- name: Rimozione dei pacchetti`

Modulo per la gestione dei pacchetti : `ansible.builtin.package:`

Verranno passati i valori della lista dei pacchetti da disinstallare : `name : "{{ item }}"`

Lo stato che vogliamo ottenere : `state: absent`

Il ciclo che scorre la lista : `loop: "{{ software.absent }}"`

Esegue le azioni solo se la lista è definita : `when: software.absent is defined`

### ansible.cfg

Il file `ansible.cfg` è il file di configurazione iniziale di Ansible.

Questo tipo di setup ha il compito di disattivare i vari warning che si presentano.

`[defaults]`

`localhost_warning = False`

`inventory_unparsed_warning = False`

`display_skipped_hosts = False` 

## REQUISITI PER L'AVVIO

E' necessario avere PODMAN o DOCKER installato.

## AVVIO

1. Scarica la cartella sul computer.
2. Aprire il terminale e posizionati nella directory del progetto.
3. Lanciare il comando `podman build -t nome_immagine . `
- L'opzione `-t`, permette di taggare l'immagine appena buildata.
- Il `.` alla fine del comando, permette di prendere il Dockerfile che abbiamo nella cartella locale per creare l'immagine.
4. Una volta completato il setup dell'immagine lanciare il comando `podman run -it --name nome_container nome_immagine `
5. Ora usiamo il comando `ansible-playbook play.yml` per eseguire il file `play.yml`, e le istruzioni saranno eseguite.

