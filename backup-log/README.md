# BACKUP LOG

Implementazione in Bash dello script **Back Log**. 

Lo script ha lo scopo di creare una cartella di backup contenente al suo interno un archivio compresso, che venga rinominato poi con un timestamp, dove viene indicato data e ora di creazione, un riepilogo di dimensione, numero e percorso dell'archivio creato.

---

## LO SCRIPT

La prima verifica : 
`if [ $# -ne 1 ]; then
    echo "Numero di argomenti non valido."
    echo "Uso: $0 directory_sorgente" 
    exit 1 
fi` 
si occupa di effettuare un test per verificare che sia stato passato un parametro, che in questo caso corrisponderà al percorso della cartella originale dei file di log.

Successivamente, viene assegnato il parametro a una variabile : 
`LOG_DIR=$1`

Viene verificato che la directory sia valida : 
`if [ ! -d "$LOG_DIR" ]; then
    echo "La directory '$LOG_DIR' non esiste o non è valida."
    exit 1 
fi` 

Impostazione del percorso per la directory di backup : 
`BACKUP_DIR="backup/"` 

Viene creata la cartella di backup se viene verificato che non esiste : 
`if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi`

Vengono contati i file di log : 
`FILE_COUNT=$(find "$LOG_DIR" -type f -name "*.log" -print0 | tr -cd '\0' | wc -c)`

Se non ci sono file di log, lo script termina : 
`if [ "$FILE_COUNT" -eq 0 ]; then
    echo "Nessun file con estensione .log trovato in '$LOG_DIR', nessun backup creato."
    exit 0
fi`

Viene creato il timestamp che verrà poi associato al nome dell'archvio : 
`TIMESTAMP=$(date +%Y%m%d_%H%M%S)`

Vengono impostati il formato del nome dell'archvio e il percorso : 
`ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}${ARCHIVE_NAME}"`

Viene creato l'archivio : 
`find "$LOG_DIR" -type f -name "*.log" -print0 | tar -czf "$ARCHIVE_PATH" --null -T - 2>/dev/null`

Verifica degli errori : 
`if [ $? -ne 0 ]; then
    echo "Errore durante la creazione dell'archivio di backup."
    exit 1
fi`

Viene estratta la dimensione dell'archivio : 
`ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)`

Viene mostrato il riepilogo :  
`echo "Backup completato!"
echo "Numero di file salvati:  $FILE_COUNT"
echo "Dimensione archivio:     $ARCHIVE_SIZE"
echo "Percorso dell'archivio:  $(realpath "$ARCHIVE_PATH")"`

---

## AVVIO

1. Scarica la cartella sul computer.
2. Aprire il terminale e posizionati nella directory del progetto.
3. Importare la cartella di log all'interno del progetto.
4. Dare i permessi di esecuzione allo script: `chmod +x backup-log.sh`
5. Lanciare il comando `./backup-log.sh ./percorso-cartella-di-log`.
