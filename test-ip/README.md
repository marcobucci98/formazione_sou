# Classificatore di Indirizzi IPv4
Questo script Bash permette di verificare la validità di un indirizzo IPv4 inserito dall'utente e di determinarne la classe di appartenenza (A, B, C, D o E), distinguendo inoltre tra indirizzi pubblici, privati e configurazioni speciali (come Loopback, APIPA o Default Route).

## Caratteristiche
- **Validazione tramite Regex:** Controlla che il formato dell'input rispetti la struttura standard `X.X.X.X`.
- **Controllo dei Limiti:** Verifica singolarmente che ognuno dei 4 ottetti non superi il valore massimo di `255`, fornendo un feedback specifico in caso di errore.
- **Riconoscimento delle Classi (A-E):** Suddivide l'indirizzo nelle classi di rete IP.
- **Rilevamento Reti Speciali:** Identifica indirizzi privati, indirizzi di Loopback (`127.X.X.X`), indirizzi APIPA (`169.254.X.X`) e la Default Route (`0.0.0.0`).

