# JINJA

Implementazione degli'esercizi di **Jinja**. 

L'esercizio consiste nell'eseguire un playbook tramite Ansible, che aggiunga in append su uno specifico file /etc/security/limits.conf alcuni settings per un’utente. 
In ambiente di produzione dobbiamo imporre un numero massimo di file aperti pari a 10000, mentre in ambiente di collaudo e sviluppo 1000. 
L'altro scopo, modificare il file /etc/security/access.conf, in modo che ci sia un’ultima riga che impedisce l’accesso agli utenti non esplicitamente autorizzati (“- : ALL : ALL”).
Il tutto viene gestito all'interno dei container con l'utilizzo di Podman.

## SVILUPPO

L'esercizio è stato sviluppato come segue: 

### DOCKERFILE

Viene scaricata una versione di Rocky Linux 9, impostato Bash come shell, viene scaricato ed installato Ansible per l'esecuzione dei playbook.
Una volta che è stato completato tutto quanto, viene impostata la cartella di lavoro e viene effettuata la copia nel container dei file necessari all'esecuzione.

`FROM rockylinux:9`

`SHELL ["/bin/bash", "-c"]`

 `RUN dnf install -y python3-pip && \`
     `dnf clean all && \`
     `pip3 install ansible-core`

`WORKDIR /root/es-jinjafiles/`

`COPY ./ansible.cfg .`
`COPY ./user_settings.yml .`
`COPY ./whitelist.yml .`

### user_settings.yml

Il primo playbook: 

Viene impostato lo stato della macchina: nome, host target, connection, privilegi root e l'utente bersaglio. 

Vengono poi definiti i valori da impostare: 

Nel caso in cui viene passato environment_type=prod, il valore sarà 10000, 1000 negli altri casi e come valore di default nel caso non venga passato nulla.

Verranno poi definite le azioni da compiere, nome, il modulo da utilizzare, percorso del file, un marcatore che segnerà inizio e fine del blocco delle modifiche e poi infine il testo che viene elaborato in base all'input che viene passato.

`---`

`- name: Configurazione del file limits.conf`  

  `hosts: localhost `
  
  `connection: local`
  
  `become: true # privilegi root`
  
  `vars: #variabili`

  `target_user: "jinjauser"`
   
  `nofile_limit: "{{ 10000 if (environment_type | default('dev')) == 'prod' else 1000 }}"`

  `tasks:` 

  `- name: Aggiungi/Aggiorna i limiti utente` 
    
  `ansible.builtin.blockinfile:`

  ` path: /etc/security/limits.conf`
  
  `marker: "# {mark} ANSIBLE MANAGED BLOCK {{ target_user }}"`
     
  `block: |` 

  `{{ target_user }} nofile {{ nofile_limit }}`

  `{{ target_user }} nofile {{ nofile_limit }}`

`...`

## AVVIO E VERIFICA

1. Scarica la cartella sul computer.
2. Aprire il terminale e posizionati nella directory del progetto.
3. Lanciare il comando `podman build -t nome_immagine . `
- L'opzione `-t`, permette di taggare l'immagine appena buildata.
- Il `.` alla fine del comando, permette di prendere il Dockerfile che abbiamo nella cartella locale per creare l'immagine.
4. Una volta completato il setup dell'immagine lanciare il comando `podman run -it --name nome_container nome_immagine `
5. Ora usiamo il comando `ansible-playbook user_settings.yml` per eseguire il file `user_settings.yml`.
- Lanciando il comando in questo modo, verrà impostato il valore di default 1000.
- Lanciando invece `ansible-playbook user_settings.yml -e "environment_type=prod" ` verrà impostato il valore 10000.
6. Per fare la verifica, andiamo a leggere il file `cat /etc/security/limits.conf `


### whitelist.yml

Il file `whitelist` ci manda alla seconda parte, viene impostato lo stato della macchina: nome, host target, connection, privilegi root e l'utente bersaglio e gli utenti da aggiungere in whitelist.
Vengono poi definite le azioni: nome, modulo, percorso del file e la regex che ricercherà “- : ALL : ALL” nel file.

Avverrà poi la fase di scrittura nel file con la sezione block.

`---`

`- name: Configurazione Whitelist`

  `hosts: localhost`

  `connection: local`

  `become: true`


  `vars:`

  `whitelist:`

  `- "alice"`

  `- "marco"`

  `- "francesco"`


  `tasks:` 

  `- name: Utenti in whitelist`

  `ansible.builtin.blockinfile:`

  `path: /etc/security/access.conf`
  
  `insertbefore: '^\-\s*:\s*ALL\s*:\s*ALL'`

  
  `block: |`

  `{% for user in whitelist %}`

  `{{ user }} : ALL`

  `{% endfor %}`

  `...`

### ansible.cfg

Il file `ansible.cfg` è il file di configurazione iniziale di Ansible.

Questo tipo di setup ha il compito di disattivare i vari warning che si presentano.

`[defaults]`

`localhost_warning = False`

`inventory_unparsed_warning = False`

`display_skipped_hosts = False` 

## REQUISITI PER L'AVVIO

E' necessario avere PODMAN o DOCKER installato.

## AVVIO E VERIFICA

1. Scarica la cartella sul computer.
2. Aprire il terminale e posizionati nella directory del progetto.
3. Lanciare il comando `podman build -t nome_immagine . `.
- L'opzione `-t`, permette di taggare l'immagine appena buildata.
- Il `.` alla fine del comando, permette di prendere il Dockerfile che abbiamo nella cartella locale per creare l'immagine.
4. Una volta completato il setup dell'immagine lanciare il comando `podman run -it --name nome_container nome_immagine`.
5. Ora usiamo il comando `ansible-playbook user_settings.yml` per eseguire il file `user_settings.yml`.
- Lanciando il comando in questo modo, verrà impostato il valore di default 1000.
- Lanciando invece `ansible-playbook user_settings.yml -e "environment_type=prod"` verrà impostato il valore 10000.
6. Per fare la verifica, andiamo a leggere il file `cat /etc/security/limits.conf`.

7. Per l'esecuzione del secondo file **yml**, usiamo il comando `ansible-playbook whitelist.yml`.
8. Potremo poi verificarne la corretta esecuzione andando al file cat `cat /etc/security/access.conf`.