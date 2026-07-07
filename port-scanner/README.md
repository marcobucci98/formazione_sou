# Port Scanner

Questo script è un **Port Scanner TCP** minimale e interattivo scritto interamente in Bash. Utilizza l'utilità di rete `nc` (Netcat) per verificare lo stato delle porte in un intervallo specificato dall'utente, su un indirizzo IP.

## Indice
1. [Funzionalità](#funzionalità)
2. [Struttura del Codice](#struttura-del-codice)
3. [Scansione UDP (Opzione non implementata)](#Scansione-UDP-(-Opzione-non-implementata-))
4. [Come Utilizzare lo Script](#come-utilizzare-lo-script)

---

## Funzionalità
- **Validazione Input**: Controlla che i campi non siano vuoti, che le porte siano numeri interi positivi, che rispettino i limiti TCP standard (1 - 65535) e che la porta di partenza sia inferiore o uguale a quella di arrivo.
- **Controllo Connettività**: Esegue un `ping` rapido per verificare se il target è raggiungibile prima di avviare la scansione (avvisando l'utente in caso negativo).
- **Scansione**: Esegue l'handshake TCP porta per porta impostando un timeout per evitare blocchi.
- **Interfaccia Ciclica**: Al termine di una scansione, chiede all'utente se desidera effettuare un nuovo controllo o uscire dal programma.

## Struttura del Codice

### Funzione `check_input()`

Questa funzione si occupa di intercettare gli errori logici e di digitazione prima che lo script interagisca con la rete:

* Controlla la presenza di tutti e tre gli input richiesti.
* Usa un'espressione regolare (`^[0-9]+$`) per assicurarsi che le porte siano numeriche.
* Applica i limiti dell'architettura TCP (range `1-65535`).
* Previene cicli infiniti errati verificando che `$start_port` non sia maggiore di `$end_port`.

### Il Ciclo Principale (`while`)

Gestisce l'interattività permettendo all'utente di eseguire scansioni multiple. All'interno del ciclo:

* Vengono richiesti i dati di input via prompt (`read`).
* Se l'input fallisce la validazione, lo script usa l'istruzione `continue` per ripulire l'esecuzione e ripartire dall'inizio.
* Viene effettuato un ping con un timeout (`-W 2`).
* Un ciclo `for` itera dalla porta iniziale a quella finale invocando il comando:
```
nc -w 1 "$target" "$port" < /dev/null > /dev/null 2>&1
```

Se l'exit status (`$?`) restituisce `0`, la porta viene dichiarata **APERTA**.

### Chiusura

Un secondo ciclo `while` annidato cattura la risposta dell'utente. 
Accetta variazioni di maiuscole e minuscole (es. `y`, `Y`, `yes`, `n`, `N`, `no`) gestendo i flussi con un costrutto `case`.

## UDP

Il protocollo UDP è connectionless, non c'è un handshake, i dati vengono semplicemente inviati.

Quando un port scanner effettua una scansione UDP :

Viene inviato un pacchetto UDP vuoto (o con payload specifici per determinati servizi) alla porta bersaglio.

PORTA CHIUSA : Nel caso la porta sia chiusa, il sistema operativo del bersaglio risponde con un messaggio di tipo "Port Unreachable".

PORTA APERTA : 
Se il pacchetto che viene inviato non contiene una richiesta formattata esattamente come l'applicazione si aspetta, l'applicazione semplicemente ignora e non risponde. 
Se la porta è filtrata da un firewall, il firewall scarta il pacchetto senza inviare una risposta. 
Nel port scanning UDP, nel momento in cui non viene data una risposta significa che la porta è probabilmente aperta (o filtrata). 
Se non si riceve nulla, lo scanner segnerà la porta come open/filtered.

## Come Utilizzare lo Script

1. **Salva il codice**: Copia il codice dello script e salvalo in un file, ad esempio `port_scanner.sh`.

2. **Assegna i permessi di esecuzione**: Apri il terminale e digita il comando seguente per rendere lo script eseguibile:
```
chmod +x port_scanner.sh
```

3. **Avvia lo script**: Esegui lo script dal terminale:
```
./port_scanner.sh
```

