// vars/eseguiScript.groovy
def call(Map config = [:]) {
    def testo = config.messaggio ?: "Ciao da Jenkins Shared Library!"
    
    def scriptContent = libraryResource('scripts/mio_script.sh')

    sh(script: """
        ${scriptContent}
    """, chmod: '0755', label: 'Esecuzione script Bash')
}