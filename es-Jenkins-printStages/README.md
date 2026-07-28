# Esercizio Jenkins PrintStages

L'esercizio riguarda una Pipeline che accetti un input dato dall'utente, che esegua uno specifico stage in base all'input dato.
L'esercizio è stato svolto utilizzando un container Docker come ambiente e l'utilizzo dell'oggetto **Date** per la gestione dei giorni.

---

## FUNZIONAMENTO

Viene avviato l'ambiente attraverso un container Docker con un'immagine di Rocky Linux 9.
Viene poi creato il menù interattivo per la selezione dell'ambiente. 
Succesivamente viene fatto il controllo attraverso **when** per selezionare lo stage da eseguire.

---

## Jenkinsfile

```
pipeline {
    agent { // container
        docker {
            image 'rockylinux/rockylinux:9'
        }
    }

    stages {
        stage('Selezione dell\' Ambiente') {
            steps {
                script {
                    // menù interattivo
                    env.ENVIRONMENT = input(
                        message: 'Seleziona lo stage da eseguire',
                        ok: 'Continua',
                        parameters: [
                            choice(
                                name: 'ENVIRONMENT', 
                                choices: ['DEVELOPMENT', 'PRODUCTION'], 
                                description: 'Quale ambiente vuoi avviare?'
                            )
                        ]
                    )
                }
            }
        }

        stage('PRODUCTION') {
            when { //controllo 
                environment name: 'ENVIRONMENT', value: 'PRODUCTION'
            }
            
            steps {
                echo "E' stato selezionato ${env.ENVIRONMENT}"
                echo "Ambiente di PRODUCTION"
            }
        }

        stage('DEVELOPMENT') {
            when { //controllo 
                environment name: 'ENVIRONMENT', value: 'DEVELOPMENT'
            }
            
            steps {
                echo "E' stato selezionato ${env.ENVIRONMENT}"
                echo "Ambiente di DEVELOPMENT"
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

---

## AVVIO

1. Aprire Jenkins e creare una nuova Pipeline.
2. Nella sezione di configurazione, cambia la selezione da Pipeline script a Pipeline script from SCM.
3. In SCM, seleziona Git.
4. Inserisci l'URL del repository **https://github.com/marcobucci98/formazione_sou**.
5. In Branch Specifier, inserire **./main**.
6. Inserire nel campo Script Path, **es-Jenkins-printStages/Jenkinsfile** e salvare.