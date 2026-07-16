#!/bin/bash

# evita interazioni durante l'installazione di pacchetti
export DEBIAN_FRONTEND=noninteractive

# aggiornamento dei pacchetti e installazione di apache
apt-get update -y
apt-get install -y apache2

# abilita e avvia il servizio apache
systemctl enable apache2
systemctl start apache2

# rimozione del file index.html 
rm -f /var/www/html/index.html

# recupera l'IP dell'interfaccia privata per capire su quale host siamo
CURRENT_IP=$(hostname -I | tr ' ' '\n' | grep '192.168.56.')

# configurazione firewall

# permette connessioni ssh
sudo ufw allow 22/tcp

# permette il traffico proveniente dal Proxy 
sudo ufw allow from 192.168.56.10 to any

# abilita UFW
sudo ufw --force enable

# configurazione della pagina html e delle regole di isolamento
if [ "$CURRENT_IP" = "192.168.56.100" ] || [[ "$CURRENT_IP" == *"56.20"* ]]; then
    
    # crea la sottocartella richiesta dal proxy per l'Host 1
    mkdir -p /var/www/html/blue
    
    cat << 'EOF' > /var/www/html/blue/index.html
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Screensaver - HOST 1</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
html,body{width:100%;height:100%;overflow:hidden;font-family:'Nunito',sans-serif;}
body{background:linear-gradient(135deg,#4da6ff 0%,#0066ff 50%,#003cb3 100%);display:flex;justify-content:center;align-items:center;color:white;position:relative;}
.blob{position:absolute;border-radius:50%;background:rgba(255,255,255,0.08);backdrop-filter:blur(5px);animation:float 12s ease-in-out infinite;}
.blob1{width:500px;height:500px;top:-150px;left:-150px;}
.blob2{width:700px;height:700px;bottom:-300px;right:-200px;animation-duration:18s;}
.blob3{width:250px;height:250px;top:60%;left:70%;animation-duration:10s;}
@keyframes float{0%,100%{transform:translateY(0px);}50%{transform:translateY(-30px);}}
.container{text-align:center;z-index:10;}
.host{font-size:2rem;font-weight:600;letter-spacing:8px;margin-bottom:25px;opacity:0.95;}
.time{font-size:9rem;font-weight:300;line-height:1;text-shadow:0 0 30px rgba(255,255,255,0.25);}
.date{margin-top:20px;font-size:2rem;font-weight:400;opacity:0.95;}
.footer{position:absolute;bottom:25px;width:100%;text-align:center;font-size:1rem;opacity:0.7;}
</style>
</head>
<body>
<div class="blob blob1"></div><div class="blob blob2"></div><div class="blob blob3"></div>
<div class="container">
    <div class="host">HOST 1</div>
    <div class="time" id="clock">00:00</div>
    <div class="date" id="date">Caricamento...</div>
</div>
<div class="footer">Sistema operativo • Screensaver</div>
<script>
function aggiornaDataOra() {
    const now = new Date();
    const ora = now.toLocaleTimeString('it-IT', {hour: '2-digit', minute: '2-digit'});
    const data = now.toLocaleDateString('it-IT', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    document.getElementById('clock').textContent = ora;
    document.getElementById('date').textContent = data.charAt(0).toUpperCase() + data.slice(1);
}
aggiornaDataOra();
setInterval(aggiornaDataOra, 1000);
</script>
</body>
</html>
EOF

    # isolamento a livello Kernel tramite iptables
    sudo iptables -I INPUT -s 192.168.56.30 -j DROP

elif [ "$CURRENT_IP" = "192.168.56.101" ] || [[ "$CURRENT_IP" == *"56.30"* ]]; then

    # crea la sottocartella richiesta dal proxy per l'Host 2
    mkdir -p /var/www/html/red

    cat << 'EOF' > /var/www/html/red/index.html
<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Screensaver - HOST 2</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
html,body{width:100%;height:100%;overflow:hidden;font-family:'Nunito',sans-serif;}
body{background:linear-gradient(135deg,#ff4d4d 0%,#e60023 50%,#b3001b 100%);display:flex;justify-content:center;align-items:center;color:white;position:relative;}
.blob{position:absolute;border-radius:50%;background:rgba(255,255,255,0.08);backdrop-filter:blur(5px);animation:float 12s ease-in-out infinite;}
.blob1{width:500px;height:500px;top:-150px;left:-150px;}
.blob2{width:700px;height:700px;bottom:-300px;right:-200px;animation-duration:18s;}
.blob3{width:250px;height:250px;top:60%;left:70%;animation-duration:10s;}
@keyframes float{0%,100%{transform:translateY(0px);}50%{transform:translateY(-30px);}}
.container{text-align:center;z-index:10;}
.host{font-size:2rem;font-weight:600;letter-spacing:8px;margin-bottom:25px;opacity:0.95;}
.time{font-size:9rem;font-weight:300;line-height:1;text-shadow:0 0 30px rgba(255,255,255,0.25);}
.date{margin-top:20px;font-size:2rem;font-weight:400;opacity:0.95;}
.footer{position:absolute;bottom:25px;width:100%;text-align:center;font-size:1rem;opacity:0.7;}
</style>
</head>
<body>
<div class="blob blob1"></div><div class="blob blob2"></div><div class="blob blob3"></div>
<div class="container">
    <div class="host">HOST 2</div>
    <div class="time" id="clock">00:00</div>
    <div class="date" id="date">Caricamento...</div>
</div>
<div class="footer">Sistema operativo • Screensaver</div>
<script>
function aggiornaDataOra() {
    const now = new Date();
    const ora = now.toLocaleTimeString('it-IT', {hour: '2-digit', minute: '2-digit'});
    const data = now.toLocaleDateString('it-IT', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    document.getElementById('clock').textContent = ora;
    document.getElementById('date').textContent = data.charAt(0).toUpperCase() + data.slice(1);
}
aggiornaDataOra();
setInterval(aggiornaDataOra, 1000);
</script>
</body>
</html>
EOF

    # isolamento a livello Kernel tramite iptables
    sudo iptables -I INPUT -s 192.168.56.20 -j DROP

else
    echo "ATTENZIONE: IP non riconosciuto, impossibile determinare l'host."
fi

# ricarica il firewall 
sudo ufw reload

# Riavvio 
systemctl restart apache2