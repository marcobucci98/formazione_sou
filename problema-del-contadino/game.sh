#!/usr/bin/env bash

# portabilità
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASE_DIR"

# avvio delle vm
echo "Avvio delle macchine virtuali..."
vagrant up

# regole
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "<                                            >"
echo "<         IL PROBLEMA DEL CONTADINO          >"
echo "<                                            >"
echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo ""
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "< Porta tutti in salvo sull'altra sponda:    >"
echo "< Fai in modo che il lupo non mangi la capra >"
echo "< e che la capra non mangi il cavolo.        >"
echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo ""

#impostazione della nuova partita
end_game() {

    read -p "Iniziare una nuova partita? (y/n): " new_game
    if [[ "$new_game" == "y" || "$new_game" == "Y" ]]; then
        echo "Caricamento nuova partita in corso..."
        sleep 1.5
        return 0 # ritorna al ciclo principale 
    else
        echo "Uscita in corso..."
        exit 0 # termina lo script
    fi
    
}

while true; do

    # reset dello stato del gioco usando array
    # 1 significa che l'elemento è presente sulla sponda, 0 è assente.
    declare -A init_edge=( [lupo]=1 [capra]=1 [cavolo]=1 [barca]=1 )
    declare -A final_edge=( [lupo]=0 [capra]=0 [cavolo]=0 [barca]=0 )
    
    edge_corr="iniziale" # traccia dove si trova la barca 
    move_prec=false      # flag per gestire le pause tra i turni

    # genera una stringa con gli elementi disponibili su una sponda
    link_element() { 

        local -n edge_rif=$1
        local str=""
        [[ ${edge_rif[lupo]} -eq 1 ]] && str+="lupo "
        [[ ${edge_rif[capra]} -eq 1 ]] && str+="capra "
        [[ ${edge_rif[cavolo]} -eq 1 ]] && str+="cavolo"
        echo "$str"

    }

    # stampa la situazione corrente
    print_map() {

    clear
    
    echo ""
    echo -n " SPONDA INIZIALE : "
    [[ ${init_edge[lupo]} -eq 1 ]] && echo -n "[Lupo] "
    [[ ${init_edge[capra]} -eq 1 ]] && echo -n "[Capra] "
    [[ ${init_edge[cavolo]} -eq 1 ]] && echo -n "[Cavolo] "
    [[ ${init_edge[barca]} -eq 1 ]] && echo -n "(BARCA)"
   
    echo -e "\n\n~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"   

    echo ""
    echo -n " SPONDA FINALE : "
    [[ ${final_edge[lupo]} -eq 1 ]] && echo -n "[Lupo] "
    [[ ${final_edge[capra]} -eq 1 ]] && echo -n "[Capra] "
    [[ ${final_edge[cavolo]} -eq 1 ]] && echo -n "[Cavolo] "
    [[ ${final_edge[barca]} -eq 1 ]] && echo -n "(BARCA)"
    echo ""
    
    echo -e "\n----------------------------------------------------"
    echo ""
    
}

    while true; do
        print_map # mostra la situazione attuale
        
        # verifiche
        # se tutti gli elementi sono sulla sponda finale, il giocatore vince.
        if [[ ${final_edge[lupo]} -eq 1 ]] && [[ ${final_edge[capra]} -eq 1 ]] && [[ ${final_edge[cavolo]} -eq 1 ]]; then
            echo "COMPLIMENTI! Hai portato tutti in salvo sulla sponda finale! YOU WIN!"
            end_game
            break # Esce dal ciclo del turno, va alla nuova partita o esce
        fi

        # verifiche di sconfitta
        if [[ ${init_edge[barca]} -eq 0 ]]; then
            if [[ ${init_edge[lupo]} -eq 1 ]] && [[ ${init_edge[capra]} -eq 1 ]]; then
                echo "GAME OVER: Il lupo ha mangiato la capra sulla sponda iniziale!"
                end_game
                break
            fi

            if [[ ${init_edge[capra]} -eq 1 ]] && [[ ${init_edge[cavolo]} -eq 1 ]]; then
                echo "GAME OVER: La capra ha mangiato il cavolo sulla sponda iniziale!"
                end_game
                break
            fi
        fi

        if [[ ${final_edge[barca]} -eq 0 ]]; then
            if [[ ${final_edge[lupo]} -eq 1 ]] && [[ ${final_edge[capra]} -eq 1 ]]; then
                echo "GAME OVER: Il lupo ha mangiato la capra sulla sponda finale!"
                end_game
                break
            fi
            if [[ ${final_edge[capra]} -eq 1 ]] && [[ ${final_edge[cavolo]} -eq 1 ]]; then
                echo "GAME OVER: La capra ha mangiato il cavolo sulla sponda finale!"
                end_game
                break
            fi
        fi

        # pausa per le verifiche
        if [ "$move_prec" = true ]; then
            echo "Ora inizierà il turno successivo..."
            move_prec=false
            print_map 
        fi

        # interazione
        rm -f .joystick.txt # Rimuove il vecchio file di input per evitare letture sporche
        
        # in base a dove si trova la barca, viene eseguito un comando con gli elementi disponibili 
        if [ "$edge_corr" == "iniziale" ]; then
            elem_disp=$(link_element init_edge) 
            # selezione
            vagrant ssh sponda_iniziale -- -t "bash /app/VM_scripts/init_edge.sh scegli '$elem_disp'" 2>/dev/null
        else
            elem_disp=$(link_element final_edge)
            vagrant ssh sponda_finale -- -t "bash /app/VM_scripts/final_edge.sh scegli '$elem_disp'" 2>/dev/null
        fi

        # lettura del file condiviso
        if [ -f .joystick.txt ]; then
            choice=$(cat .joystick.txt | tr -d '\r\n ')
        else
            choice="ERRORE_INPUT"
        fi

        # uscita dal gioco
        if [ "$choice" == "exit" ]; then 
            echo "Uscita dal gioco..."
            exit 0
        fi
        
        if [ "$choice" == "ERRORE_INPUT" ]; then
            echo "Mossa non valida: l'elemento inserito non è presente su questa sponda!"
            sleep 2
            continue # salta il resto del turno 
        fi

        # aggiornamento dello stato
        # se la barca era sulla sponda iniziale, si sposta su quella finale (e sposta l'eventuale elemento scelto)
        if [ "$edge_corr" == "iniziale" ]; then
            init_edge[barca]=0
            final_edge[barca]=1
            if [ "$choice" != "nessuno" ]; then
                init_edge[$choice]=0
                final_edge[$choice]=1
            fi
            edge_corr="finale" 
        else
            final_edge[barca]=0
            init_edge[barca]=1
            if [ "$choice" != "nessuno" ]; then
                final_edge[$choice]=0
                init_edge[$choice]=1
            fi
            edge_corr="iniziale"
        fi

        move_prec=true # mossa valida
    done
done