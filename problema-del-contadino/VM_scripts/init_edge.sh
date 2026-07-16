#!/usr/bin/env bash

# Recupera i due parametri passati dallo script principale 
act=$1          # L'azione da compiere 
elem_pres=$2    # contiene gli elementi presenti su questa sponda 

case "$act" in
    "scegli")

        echo "SPONDA INIZIALE : La barca è pronta."
        echo "Puoi selezionare : [ $elem_pres nessuno ] o exit per uscire "
        
        # input dell'utente
        read -p "Cosa vuoi imbarcare? : " choice
        echo "Hai selezionato: $choice "
        
        # se la variabile choice è vuota, imposta di default il valore a "nessuno" 
        [ -z "$choice" ] && choice="nessuno"
        
        # scrive la scelta 
        if [ "$choice" == "exit" ] || [ "$choice" == "nessuno" ]; then
            echo "$choice" > /app/.joystick.txt
            exit 0
        fi

        # verifica della scelta dell'utente 
        if [[ " $elem_pres " =~ " $choice " ]]; then
            # Se l'elemento è presente, scrive il nome dell'elemento nel file joystick
            echo "$choice" > /app/.joystick.txt
        else
            echo "ERRORE_INPUT" > /app/.joystick.txt
        fi
        ;;
esac