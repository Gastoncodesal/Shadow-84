#!/usr/bin/env python3
"""Verifica la integridad física del TP sin suplantar el test de Godot."""
from pathlib import Path
import json,re,sys,wave,struct,zlib
base=Path(__file__).resolve().parents[1]
root=base/'template'
fallos=[]
refs=[]
for archivo in list(root.rglob('*.gd')) + list(root.rglob('*.tscn')) + [root/'project.godot']:
    txt=archivo.read_text(encoding='utf-8')
    for ref in re.findall(r'res://([^\"\']+)',txt):
        # recursos de preloads, scripts, iconos, escenas y sonidos
        if not (root/ref).is_file():
            fallos.append(f"Recurso faltante {archivo.relative_to(root)} -> {ref}")
        refs.append(ref)
    if '\t' in txt and archivo.suffix=='.gd':
        fallos.append(f"Archivo con tabulaciones: {archivo}")
for img in root.rglob('*.png'):
    try:
        data=img.read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n':
            raise ValueError('Cabecera PNG inválida')
        ancho,alto=struct.unpack('>II',data[16:24])
        if ancho<=0 or alto<=0:
            raise ValueError('Dimensiones inválidas')
    except Exception as e:
        fallos.append(f"Imagen dañada {img}: {e}")
for sonido in root.rglob('*.wav'):
    try:
        with wave.open(str(sonido),'rb') as w:
            if w.getnframes()<=0: fallos.append(f"Audio vacío: {sonido}")
    except Exception as e:
        fallos.append(f"Audio dañado {sonido}: {e}")
with (root/'guion/capitulo_1.json').open(encoding='utf-8') as f:
    datos=json.load(f)
nodos=datos['nodos']
for id,nodo in nodos.items():
    for opcion in nodo.get('opciones',[]):
        if opcion.get('goto') not in nodos: fallos.append(f"Salto inválido: {id}")
        if not {'txt','cond','efecto','goto'}.issubset(opcion):fallos.append(f"Opción incompleta: {id}")
    if nodo.get('goto') and nodo['goto'] not in nodos:
        fallos.append(f"Destino inexistente {id}")
for id in ['FIN_SACRIFICIO','FIN_DESPERTAR','FIN_SHOGUN']:
    if id not in nodos or not nodos[id].get('fin'):fallos.append(f"Falta final {id}")
for path in ['scripts/pantalla_inicio.gd','recursos/portrait_ren.png','recursos/portrait_aiko.png','recursos/portrait_raiden.png']:
    if not (root/path).is_file():fallos.append(f"Falta nuevo recurso {path}")
print(f"Archivos: {sum(1 for x in root.rglob('*') if x.is_file())} | Referencias: {len(refs)} | Nodos narrativos: {len(nodos)} | PNG: {len(list(root.rglob('*.png')))} | WAV: {len(list(root.rglob('*.wav')))}")
if fallos:
    print('ERRORES:')
    for f in fallos: print(' -',f)
    sys.exit(1)
print('OK — referencias y recursos válidos. Pendiente ejecutar Godot y playtest.')
