# Gestione Utenti tramite Playbook

Implementazione del'esercizio **Gestione Utenti**. 

L'esercizio consiste nell'eseguire un playbook tramite Ansible, che crei degli utenti, con le loro caretteristiche, prendendo gli elementi dai dizionari `username` contenuti nella lista `utenti`.
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

### play.yml

Il playbook che verrà eseguito : 

Titolo : `- name: Gestione degli utenti `

Specifica su quali macchine eseguire il playbook : `hosts: localhost`

Esegue i comandi direttamente sulla macchina locale : `connection: local`

Variabili : `vars:`

Lista : `utenti:` 

Elementi di ogni utente : 

    `group: "xxx" # gruppo primario `

    `groups: ["xxx", "xxx"] # gruppi secondari`

    `shell: "xxx" # specifica la shell`
        
    `home: "xxx" # cartella personale`

Azioni : `tasks`

    - name: Gruppi secondari # titolo

      ansible.builtin.group: # modulo

        name: "{{ item }}" # assegna al gruppo il nome dell'elemento corrente preso dal ciclo

        state: present # crea il gruppo

      loop: "{{ utenti | map(attribute='groups') | flatten | unique }}" # legge la sezione groups, unifica ed elimina i duplicati

Seconda task:

       - name: Creazione degli utenti # titolo

      ansible.builtin.user: # modulo

        name: "{{ item.username }}" # imposta username
        
        group: "{{ item.group }}" # imposta il gruppo primario
        
        groups: "{{ item.groups }}" # imposta i gruppi 
        secondari
        
        shell: "{{ item.shell }}" # imposta la shell
        
        home: "{{ item.home }}" # imposta la home 
        
        state: present # verifica se l'utente esiste
        
        append: true # aggiunge ai gruppi secondari
      
      loop: "{{ utenti }}" # ripete per ogni utente
      
      loop_control: # configurazione del ciclo
        label: "{{ item.username }}" # stampa il nome utente

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
5. Ora usiamo il comando `ansible-playbook play.yml` per eseguire il file `play.yml`.
6. Per fare la verifica degli utenti e gruppi creati usiamo `getent passwd ` e `getent group`: 

- `getent passwd` : 

- - `m.rossi:x:1000:1002::/home/mrossi:/bin/bash`

- - `m.rossi` : username

- - `x` : password

- - `1000` : UID

- - `1002` : GID

- - `::` : commento (non impostato)

- - `/home/mrossi` : home directory

- - `/bin/bash` : shell predefinita

- `getent group` : 

- - `direzione:x:1002:f.bianchi,g.verdi `

- - `direzione` : nome gruppo

- - `x` : password del gruppo (non impostata)

- - `1002` : GID

- - `f.bianchi,g.verdi` : mostra gli utenti per i quali direzione è un gruppo secondario

