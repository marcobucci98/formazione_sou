## Reverse Proxy

### Presentazione e Funzionamento

Il progetto consiste nella progettazione e nell'implementazione automatizzata di un'infrastruttura di rete multi-nodo locale, mirata a riprodurre un ambiente di produzione scalabile e sicuro. 
Sfruttando la combinazione di Vagrant e VirtualBox, l'intera architettura viene configurata e interconnessa in modo automatico tramite script in ambiente Ubuntu Server.

L'infrastruttura si basa sulla logica del Reverse Proxy con SSL Termination e Path-Based Routing, i nodi sono interconnessi tramite rete privata (192.168.56.0/24):
* **proxy-server (IP 192.168.56.10):** Rappresenta il punto di ingresso, gestisce le richieste del client e la crittografia.

* **server1 (IP 192.168.56.20):** Il primo server web, tramite il quale, visitando l'indirizzo https://192.168.56.10/blue/, riporta alla pagina web che visualizza un semplice screensaver in sfondo blu.

* **server2 (IP 192.168.56.30):** Il secondo server web, tramite il quale, visitando l'indirizzo https://192.168.56.10/red/, riporta alla pagina web che visualizza un semplice screensaver in sfondo rosso.

Per far funzionare tutta la struttura bisogna semplicemente lanciare il comando vagrant up. 

### Accesso all'Infrastruttura
Quando un utente tenta di accedere a uno dei servizi tramite browser, effettua una richiesta cifrata utilizzando il protocollo sicuro HTTPS sulla porta inoltrata 8443 dell'host locale (mappata sulla porta standard 443 della macchina virtuale proxy).
Il proxy-server accetta la connessione sfruttando un certificato SSL/TLS, generato tramite OpenSSL. 

### Percorso e Instradamento 
Una volta decifrato il pacchetto dati, il modulo mod_proxy di Apache analizza la struttura dell'URL richiesto (Path Routing) per determinare la destinazione corretta:
* Se l'URL punta al percorso `/blue/`, il proxy instrada la richiesta in chiaro (HTTP sulla porta standard 80) verso l'IP privato del primo backend (`192.168.56.20/blue/`).
* Se l'URL punta al percorso `/red/`, il proxy reindirizza il traffico in chiaro verso il secondo backend (`192.168.56.30/red/`).
* Qualsiasi richiesta verso percorsi non mappati viene rifiutata con un errore standard.
I server di backend server1 e server2 eseguono una configurazione condizionale in fase di avvio. 

Attraverso lo script di provisioning, ogni macchina interroga la propria interfaccia di rete privata per identificare il proprio IP. 
In base all'IP rilevato, creano esclusivamente la specifica sottocartella richiesta dal proxy (`/var/www/html/blue` o `/var/www/html/red`) all'interno della quale generano una pagina web interattiva contenente uno screensaver e un orologio.

### Risposta Protetta al Client
Il Reverse Proxy riceve il contenuto web in chiaro inviato dal backend, lo incapsula nuovamente all'interno del canale cifrato SSL/TLS precedentemente stabilito con l'utente e spedisce la risposta finale al browser in modalità protetta (HTTPS).