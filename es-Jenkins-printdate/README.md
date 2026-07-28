# Esercizio Jenkins PrintDate

L'esercizio riguarda una Pipeline che controlla dinamicamente il giorno della settimana corrente e decide se eseguire il processo di build o stampare un messaggio di avviso durante il fine settimana.
L'esrcizio è stato svolto utilizzando un container Docker come ambiente e l'utilizzo dell'oggetto **Date** per la gestione dei giorni.

---

## FUNZIONAMENTO

Viene avviato l'ambiente attraverso un container Docker con un'immagine di Rocky Linux 9.
Viene poi inizializzato lo stage in cui verranno fatte le operazione di controllo e di verifica.
Vengono inizializzati tre parametri che saranno usati per la gestione dei giorni: 

**day** : al quale viene associato l'oggetto Date.
**day_name** : che viene utilizzato per impostare il formato e l'orario.
**num_day** : viene associato un numero da 1 a 7 in base al giorno della settimana.

La condizione : `if (num_day == Calendar.SATURDAY || num_day == Calendar.SUNDAY)`, permette di verificare se il numero ottenuto dall'istruzione `day.getAt(Calendar.DAY_OF_WEEK)` corrisponde al SABATO o alla DOMENICA.
Se corrisponde viene stampato il warning, altrimenti, l'esecuzione continua con la struttura **ELSE**, che stamperà il giorno attuale. 

---

## Jenkinsfile

```
pipeline {
    agent {
        docker {
            image 'rockylinux/rockylinux:9'
        }
    }
    stages {
        stage('Controllo & Build') {
            steps {
                script {

                    // inizializzato l'oggetto Date 
                    def day = new Date()
                    
                    // impostazione del formato e orario
                    def day_name = day.format('EEEE', TimeZone.getTimeZone('Europe/Rome'))
                    
                    // ottiene il giorno della settimana, viene poi calcolato un numero da 1 a 7 da associare ai giorni
                    def num_day = day.getAt(Calendar.DAY_OF_WEEK)
                
                    //stampa del giorno corrente
                    echo "Oggi è: ${day_name}"

                    // controllo per la verifica
                    if (num_day == Calendar.SATURDAY || num_day == Calendar.SUNDAY) {
                        // warning per i giorni del weekend                    
                        echo "Oggi è ${day_name}! Nessuna build programmata nel weekend."                        
                    } 
                
                    else {
                        //stampa ed esecuzione
                        echo "Giorno : ${day_name}: Esecuzione..."

                    }
                }
            }
        }
    }
}
```

---

## REQUISITI

* **Jenkins**
* **Docker**
* **Plugins**:
  * *Docker* 
* **Java**

Se Jenkins è stato installato attraverso i gestori **apt** o **dnf**, Java sarà già installato, considerato requisito fondamentale per l'avvio di Jenkins.

---

## AVVIO

1. Aprire Jenkins e creare una nuova Pipeline.
2. Nella sezione di configurazione, cambia la selezione da Pipeline script a Pipeline script from SCM.
3. In SCM, seleziona Git.
4. Inserisci l'URL del repository **https://github.com/marcobucci98/formazione_sou**.
5. In Branch Specifier, inserire **./main**.
6. Inserire nel campo Script Path, **es-Jenkins-printdate/Jenkinsfile** e salvare.