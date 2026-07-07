#!/bin/bash

# verifica
check_input() {
    # verifica che i campi non siano vuoti
    if [ -z "$target" ] || [ -z "$start_port" ] || [ -z "$end_port" ]; then
        echo "Errore: Tutti i campi sono obbligatori."
        return 1
    fi

    # verifica che le porte siano numeri interi positivi
    local re_numero='^[0-9]+$'
    if ! [[ "$start_port" =~ $re_numero ]] || ! [[ "$end_port" =~ $re_numero ]]; then
        echo "Errore: Le porte devono essere numeri interi positivi."
        return 1
    fi

    # verifica dei limiti del range delle porte TCP (1 - 65535)
    if [ "$start_port" -lt 1 ] || [ "$start_port" -gt 65535 ] || \
       [ "$end_port" -lt 1 ] || [ "$end_port" -gt 65535 ]; then
        echo "Errore: Il range delle porte deve essere compreso tra 1 e 65535."
        return 1
    fi

    # verifica che la porta iniziale non sia maggiore della finale
    if [ "$start_port" -gt "$end_port" ]; then
        echo "Errore: La porta iniziale non può essere maggiore della porta finale."
        return 1
    fi

    return 0
}

while true; do  

    echo " SCANSIONE PORT SCANNER "

    # inserimento dati
    read -p "Inserisci l'IP o l'Hostname del target: " target
    read -p "Inserisci la porta INIZIALE : " start_port
    read -p "Inserisci la porta FINALE : " end_port

    # controllo validità 
    if ! check_input; then
        echo -e "Configurazione non valida. Riprova.\n"
        continue
    fi

    # verifica della connettività
    echo "Verifica connettività verso $target (Ping)..."
    if ! ping -c 1 -W 2 "$target" > /dev/null 2>&1; then
        echo "Attenzione: Il target $target non risponde al ping."
    fi

    # port scanning
    echo "Inizio scansione TCP su: $target"
    echo "Controllo porte : $start_port -> $end_port"

    # invoca nc per ogni porta
    for ((port=start_port; port<=end_port; port++)); do
        
        # nc viene forzato a chiudersi subito dopo l'handshake usando < /dev/null
        nc -w 1 "$target" "$port" < /dev/null > /dev/null 2>&1
    
        # se l'exit status è 0, la porta ha risposto
        if [ $? -eq 0 ]; then
            echo "Porta $port: APERTA"
        fi
    done

    echo "Scansione completata."

    # gestione del ciclo
    while true; do
        read -p "Vuoi effettuare un'altra scansione? (y/n): " risposta
        case "$risposta" in 
            [Yy]* ) 
                break # Rompe questo ciclo interno e torna all'inizio del loop principale
                ;; 

            [Nn]* ) 
                exit 0 # Chiude definitivamente lo script
                ;; 

            * ) 
                echo "Risposta non valida! Inserisci 'y' per sì o 'n' per no."
                ;;

        esac

    done

done