#!/bin/bash

# verifica che sia stato passato un parametro 
if [ $# -ne 1 ]; then
    echo "Numero di argomenti non valido."
    echo "Uso: $0 directory_sorgente" 
    exit 1 
fi

# assegna l'argomento passato alla variabile LOG_DIR
LOG_DIR=$1

# verifica della directory 
if [ ! -d "$LOG_DIR" ]; then
    echo "La directory '$LOG_DIR' non esiste o non è valida."
    exit 1 
fi

# percorso della cartella dove salvare i backup
BACKUP_DIR="backup/"

# crea la cartella di backup se non esiste
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# conta i file log 
FILE_COUNT=$(find "$LOG_DIR" -type f -name "*.log" -print0 | tr -cd '\0' | wc -c)

# se non ci sono file log, esce dallo script 
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "Nessun file con estensione .log trovato in '$LOG_DIR', nessun backup creato."
    exit 0
fi

# formato
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# nome e percorso
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}${ARCHIVE_NAME}"

# crea l'archivio compresso .tar.gz 
find "$LOG_DIR" -type f -name "*.log" -print0 | tar -czf "$ARCHIVE_PATH" --null -T - 2>/dev/null

# verifica di errori
if [ $? -ne 0 ]; then
    echo "Errore durante la creazione dell'archivio di backup."
    exit 1
fi

# calcola la dimensione dell'archivio
ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)

#riepilogo 
echo "Backup completato!"
echo "Numero di file salvati:  $FILE_COUNT"
echo "Dimensione archivio:     $ARCHIVE_SIZE"
echo "Percorso dell'archivio:  $(realpath "$ARCHIVE_PATH")"
