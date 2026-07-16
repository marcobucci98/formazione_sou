# IL PROBLEMA DEL CONTADINO

Implementazione in Bash dell' indovinello logico del **Problema del Contadino**. 

Lo script di gioco principale viene eseguito sulla macchina host, mentre l'input dell'utente e la gestione delle singole sponde sono delegati a due macchine virtuali distinte (`sponda_iniziale` e `sponda_finale`).

---

## REGOLE DEL GIOCO

Il contadino deve trasportare un **lupo**, una **capra** e un **cavolo** da una sponda all'altra di un fiume usando una barca che può contenere solo lui e un elemento alla volta. 
* Se lasciati incustoditi sulla stessa sponda:
  * Il **lupo mangia la capra**.
  * La **capra mangia il cavolo**.
* L'obiettivo è portare tutti sani e salvi sulla sponda finale.

---

## ARCHITETTURA DEL PROGETTO

Il gioco si sviluppa su un sistema di comunicazione tramite una cartella condivisa (mappata in `/app` nelle VM):

1. **Host:** Gestisce lo stato del gioco (matrici di presenza degli elementi), verifica le condizioni di vittoria e sconfitta e imposta la mappa.

2. **VM `sponda_iniziale` & `sponda_finale`:** In base alla posizione della barca, l'host si connette alla VM della sponda corrente ed esegue lo script di input.

3. **(`.joystick.txt`):** L'utente inserisce cosa trasportare sulla sponda opposta; la VM valida la mossa e scrive la scelta sull' file condiviso, che viene letto ed elaborato dall'host.

---

## AVVIO

1. Scarica la cartella sul computer.
2. Aprire il terminale e posizionati nella directory del progetto.
3. Dare  i permessi di esecuzione allo script principale: `chmod +x game.sh`
4. Lanciare il comando `./game.sh`, e le macchine virtuali si avvieranno automaticamento insieme allo script del gioco.
