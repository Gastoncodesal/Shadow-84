from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path
import math, random
P=Path(__file__).resolve().parents[1] / 'template' / 'recursos'
P.mkdir(exist_ok=True)
fontpath='/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf'

def RGB(c): return tuple(bytes.fromhex(c.lstrip('#')))
def rect(d,box,c):d.rectangle(tuple(map(int,box)),fill=RGB(c) if isinstance(c,str) else c)
def poly(d,points,c):d.polygon(points,fill=RGB(c) if isinstance(c,str) else c)
def ln(d,points,c,w=1):d.line(points,fill=RGB(c) if isinstance(c,str) else c,width=w)
def txt(d,at,s,color,size=10):
 try: fuente=ImageFont.truetype(fontpath,size)
 except OSError: fuente=ImageFont.load_default()
 d.text(at,s,font=fuente,fill=RGB(color))

def backdrop(n,seed):
 r=random.Random(seed); W,H=480,720
 config=[
 ('0a1024','251841','0a142d','17d9ed','ee3a91','83b7e5','34bff6','ROOFTOPS // ZONA 01'),
 ('111622','352c30','111820','ffd36c','fc6b4e','e6a76e','d9ba54','FORJA // ZONA 02'),
 ('100d25','351732','140f26','eb4d9a','9b75ff','dd8eca','a08fff','CIUDADELA // ZONA 03'),
 ('090a18','27101a','0d0a1b','ff4a65','ffcc86','b15b83','ff526d','NUCLEO // KUROGANE')
 ][n]
 top,bot,building,cyan,pink,fog,light,name=config
 im=Image.new('RGB',(W,H)); d=ImageDraw.Draw(im)
 t=RGB(top);b=RGB(bot)
 for y in range(H):
  f=y/H; cc=tuple(int(a*(1-f)+z*f) for a,z in zip(t,b)); ln(d,[(0,y),(W,y)],cc)
 # distant smog beams
 for i in range(70):
  x=r.randint(0,W);y=r.randint(62,480)
  rect(d,(x,y,x+r.randint(1,2),y+1),tuple(int(v*0.7) for v in RGB(light)))
 if n!=3:
  mx,my=(368,174) if n==0 else ((110,170) if n==1 else (380,145))
  for rad,alpha in [(66,12),(54,20),(41,32)]:
   shade=Image.new('RGBA',(W,H),(0,0,0,0));sd=ImageDraw.Draw(shade)
   sd.ellipse((mx-rad,my-rad,mx+rad,my+rad),fill=(*RGB(pink),alpha));im=Image.alpha_composite(im.convert('RGBA'),shade).convert('RGB')
  d=ImageDraw.Draw(im); d.ellipse((mx-28,my-28,mx+28,my+28),fill=RGB('8d83a3' if n==0 else 'a87778'))
  d.ellipse((mx-25,my-27,mx+25,my+23),fill=RGB('d7abb9' if n==0 else 'dd9c91'))
  for j in range(7):
   x=mx+r.randint(-17,17);y=my+r.randint(-20,18);d.ellipse((x-3,y-3,x+3,y+3),fill=RGB('c190b1' if n==0 else 'c68c80'))
 # far skyline silhouette
 for i in range(25):
  x=i*22-12;h=r.randrange(100,240); y=535-h
  rect(d,(x,y,x+25,572),RGB('141934' if n==0 else ('26242b' if n==1 else '1a1328')))
  for yy in range(y+12,565,15):
   for xx in range(x+5,x+22,9):
    if r.random()<.34:rect(d,(xx,yy,xx+3,yy+5),RGB('324267' if n!=1 else '695345'))
 # back buildings architecture
 for i in range(9):
  x=i*61-22;h=r.randint(120,240);y=550-h
  fill=['121c35','25212e','1f152d','1c111c'][n];trim=cyan if i%3 else pink
  rect(d,(x,y,x+58,665),fill)
  rect(d,(x,y,x+58,y+3),RGB(trim))
  for yy in range(y+15,555,22):
   for xx in range(x+9,x+53,13):
    if r.random()>.25:
     rect(d,(xx,yy,xx+5,yy+8), RGB('366183' if n==0 else ('8b754a' if n==1 else ('6a3f78' if n==2 else '793944'))))
  if i%2==0:
   rect(d,(x+42,y+16,x+54,y+67),trim)
   rect(d,(x+45,y+20,x+51,y+64),'ffffff' if n==1 else '321f44')
 # special architecture per stage
 if n==0:
  # roof silhouettes with layered pagoda roofs / antennae
  for xx,base in [(25,434),(210,392),(374,447)]:
   rect(d,(xx,base+12,xx+88,600),'0e162b')
   for yy,ww in [(base,95),(base-40,68)]:
    poly(d,[(xx-13,yy+15),(xx+45,yy-1),(xx+98,yy+15),(xx+87,yy+20),(xx-4,yy+20)],'171d35')
    ln(d,[(xx-13,yy+15),(xx+45,yy-1),(xx+98,yy+15)],cyan,2)
   rect(d,(xx+28,base-50,xx+62,base-39),'171d35')
  # billboards
  rect(d,(143,337,190,399),'e93289');rect(d,(147,342,187,395),'29172f');txt(d,(151,349),'84','72f8f3',20);txt(d,(151,374),'NEO','fc81be',8)
 if n==1:
  # foundry stacks, rails and pipes
  for x in [33,136,283,418]:
   rect(d,(x,235,x+23,600),'292632');rect(d,(x-4,230,x+26,246),'9b583b')
   for yy in range(260,520,27):rect(d,(x+3,yy,x+19,yy+5),'5b4e40')
  for y in [318,370,451]:
   rect(d,(0,y,480,y+11),'39373a');rect(d,(0,y+3,480,y+5),'db7645')
   for x in range(13,480,80):rect(d,(x,y-10,x+8,y+24),'423738')
  # steam clouds / vents
  for x in [73,246,397]:
   for j in range(6):
    xx=x+r.randrange(-30,30); yy=219-r.randrange(0,80)
    d.ellipse((xx,yy,xx+39,yy+19),fill=RGB('51434a'))
 if n==2:
  # tower + massive gate
  poly(d,[(154,445),(154,235),(196,200),(282,200),(327,240),(327,558)],'191322')
  for x in [165,282]:
   rect(d,(x,265,x+30,555),'3e273d')
   for y in range(290,490,39):rect(d,(x+7,y,x+24,y+20),'79426c')
  rect(d,(204,291,275,590),'110d20');rect(d,(214,310,265,585),'2f193b')
  ln(d,[(214,310),(214,585)],pink,3);ln(d,[(265,310),(265,585)],pink,3)
  for y in range(336,556,22):ln(d,[(219,y),(259,y)],cyan,1)
  poly(d,[(132,238),(242,167),(351,238),(341,252),(242,202),(144,252)],'361c39')
  ln(d,[(132,238),(242,167),(351,238)],pink,4)
  txt(d,(191,234),'KUROGANE','f1b7d5',11)
 if n==3:
  # symmetric final core
  for x in [15,415]:
   rect(d,(x,140,x+49,620),'251723');rect(d,(x+7,160,x+41,595),'4b202e')
   for y in range(176,585,44):rect(d,(x+10,y,x+37,y+3),pink)
  for rad in [148,124,101,83,68]:
   d.ellipse((240-rad,319-rad,240+rad,319+rad),outline=RGB('7b364b' if rad>100 else pink),width=4)
  d.ellipse((201,281,279,359),fill=RGB('311525'),outline=RGB('ff6b75'),width=3)
  for a in range(0,360,30):
   rad=math.radians(a);x=240+math.cos(rad)*110;y=319+math.sin(rad)*110
   ln(d,[(240,319),(x,y)],'6e2b42',2)
  txt(d,(157,115),'PROTOCOL: SILENCIO','ff7e9b',11)
  for x in range(102,377,55):
   rect(d,(x,520,x+12,585),'281927')
   rect(d,(x,525,x+12,530),pink)
 # foreground walkway: receding synthwave city perspective
 rect(d,(0,579,480,720),'080d19' if n!=3 else '110d18')
 ln(d,[(0,579),(480,579)],cyan,3)
 for i in range(10):
  y=int(585+(i/9)**1.8*136)
  ln(d,[(0,y),(480,y)],'123449' if n==0 else ('4e3f32' if n==1 else ('3b2849' if n==2 else '4c2235')),1)
 for x in range(-200,750,70):
  ln(d,[(240,580),(x,720)],'10253c' if n==0 else ('302a2a' if n==1 else ('2c233b' if n==2 else '3c2132')),1)
 # foreground frame, signage etc
 for i in range(5):
  x=18+i*105
  rect(d,(x,560,x+8,613),'19243a' if n==0 else '282233')
  rect(d,(x-3,558,x+11,564),pink)
  if i%2==0: rect(d,(x+3,567,x+5,596),cyan)
 # vignette overlay
 im=im.convert('RGBA');overlay=Image.new('RGBA',(W,H),(0,0,0,0));od=ImageDraw.Draw(overlay)
 for yy in range(0,720,3):
  od.rectangle((0,yy,480,yy),fill=(0,0,0,15))
 im=Image.alpha_composite(im,overlay).convert('RGB')
 im.save(P/f'escenario_{n+1}.png',optimize=True)

def draw_ninja(frame):
 I=Image.new('RGBA',(72,80)); d=ImageDraw.Draw(I)
 bob=(frame%4==1)*2; lean=0 if frame<4 else (1 if frame%2 else -1)*3
 def R(bb,c):rect(d,[bb[0]+lean,bb[1]+bob,bb[2]+lean,bb[3]+bob],c)
 def L(pp,c,w=1):ln(d,[(x+lean,y+bob) for x,y in pp],c,w)
 # scarf wind 
 poly(d,[(45,19+bob),(62+frame%4*2,14+bob),(67,18+bob),(52,25+bob),(46,23+bob)],'fd476d')
 poly(d,[(45,23+bob),(60+frame%3*2,29+bob),(58,32+bob),(44,29+bob)],'a8264e')
 # katana back
 L([(50,17),(57,47)],'82d8de',4);L([(51,18),(58,47)],'d4f8f9',1)
 R((17,52,29,72),'111929');R((39,52,50,72),'111929')
 R((15,67,30,74),'26324b');R((38,67,52,74),'26324b')
 R((15,31,20,57),'121928');R((48,31,53,57),'121928')
 R((11,42,22,49),'24344b');R((47,42,58,49),'24344b')
 R((20,28,49,61),'172139');R((24,32,46,52),'304262')
 R((27,32,40,50),'1c2c44');R((20,42,49,46),'ed3c70')
 R((22,50,46,54),'476882')
 R((21,12,49,34),'121a2e');R((24,9,47,14),'26334b')
 R((19,18,51,28),'171e35');R((22,21,48,29),'3a5069')
 R((20,20,50,23),'f24d78')
 R((23,25,48,32),'b2ccd6');R((24,27,47,30),'111927')
 R((25,27,32,30),'34f3f3');R((40,27,47,30),'34f3f3')
 R((31,32,40,38),'101827')
 R((20,33,25,41),'122239');R((44,33,49,41),'122239')
 R((27,57,32,61),'42d8df');R((38,57,43,61),'42d8df')
 # motion frames weapon slash
 if frame>=4:
  L([(53,40),(67,22)],'affafe',3)
  L([(55,41),(69,24)],'32cfdc',1)
 I.save(P/f'ren_{frame}.png')

def draw_enemy(t,frame):
 I=Image.new('RGBA',(56,56));d=ImageDraw.Draw(I)
 c=['3ee8ed','eb76fa','f6a65a'][t]
 shift=frame%2
 def R(bb,k):rect(d,(bb[0],bb[1]+shift,bb[2],bb[3]+shift),k)
 R((11,42,23,49),'29354d');R((33,42,45,49),'29354d')
 R((7,20,49,44),'141d2b');R((12,23,44,41),'3d455c')
 R((3,26,12,39),'263b50');R((45,26,53,39),'263b50')
 R((13,9,44,28),'121b2e');R((16,10,42,16),'48526a')
 if t==0:
  poly(d,[(12,12),(4,5),(7,26),(18,25)],'47556f')
  poly(d,[(44,12),(52,5),(49,26),(38,25)],'47556f')
 if t==1:
  poly(d,[(10,9),(29,2),(46,9),(39,14),(18,14)],'74376f')
  R((15,30,41,34),'ab4fa4')
 if t==2:
  poly(d,[(4,17),(18,10),(19,21),(5,25)],'86684f')
  poly(d,[(52,17),(38,10),(37,21),(51,25)],'86684f')
  R((12,34,44,38),'ac705a')
 R((14,18,42,27),c);R((19,19,37,25),'071322')
 R((20,20,25,23),'d9f9ff');R((31,20,36,23),'d9f9ff')
 R((24,30,33,39),c);R((27,32,30,37),'ffffff')
 R((7,31,12,36),c);R((45,31,49,36),c)
 I.save(P/f'centinela_{t}_{frame}.png')

def draw_boss(phase,frame):
 I=Image.new('RGBA',(164,142));d=ImageDraw.Draw(I)
 main=['ec608b','ff9b56','ff3e65'][phase]
 l=['653b8e','924d34','93263e'][phase]
 bob=frame%2*3
 # wing arrays blades
 for side in [-1,1]:
  xx=lambda v:82+side*v
  wing=[(xx(39),32+bob),(xx(70),17+bob),(xx(78),37+bob),(xx(66),66+bob),(xx(76),93+bob),(xx(45),104+bob),(xx(28),85+bob)]
  poly(d,wing,'181a2c');ln(d,wing+[wing[0]],l,3)
  poly(d,[(xx(43),45+bob),(xx(68),30+bob),(xx(59),64+bob),(xx(43),68+bob)],'39425a')
  ln(d,[(xx(45),45+bob),(xx(58),34+bob)],main,4)
  poly(d,[(xx(38),85+bob),(xx(68),113+bob),(xx(74),125+bob),(xx(44),112+bob)],l)
 # core body
 poly(d,[(52,33+bob),(112,33+bob),(127,58+bob),(115,117+bob),(50,117+bob),(37,58+bob)],'111524')
 poly(d,[(57,40+bob),(107,40+bob),(116,61+bob),(106,107+bob),(57,107+bob),(47,61+bob)],'384054')
 rect(d,(57,68+bob,107,78+bob),l)
 # mask and horns
 poly(d,[(57,21+bob),(42,0+bob),(68,13+bob)],main)
 poly(d,[(107,21+bob),(122,0+bob),(96,13+bob)],main)
 poly(d,[(56,18+bob),(108,18+bob),(120,46+bob),(105,65+bob),(58,65+bob),(44,46+bob)],'151a2c')
 poly(d,[(62,24+bob),(103,24+bob),(110,44+bob),(82,61+bob),(55,44+bob)],'35364c')
 poly(d,[(58,40+bob),(79,47+bob),(79,52+bob),(57,49+bob)],main)
 poly(d,[(86,47+bob),(107,40+bob),(108,49+bob),(86,52+bob)],main)
 poly(d,[(70,56+bob),(94,56+bob),(90,63+bob),(74,63+bob)],'111524')
 # reactor halo and core
 for rad,col in [(24,l),(19,main),(13,'15131f'),(7,'ffffff')]:
  d.ellipse((82-rad,90+bob-rad,82+rad,90+bob+rad),fill=RGB(col))
 for y in range(101,117,5):
  rect(d,(70,y+bob,94,y+2+bob),main)
 I.save(P/f'raiden_{phase}_{frame}.png')

def shuriken():
 im=Image.new('RGBA',(28,28));d=ImageDraw.Draw(im)
 for rot in range(4):
  a=rot*math.pi/2
  points=[]
  for x,y in [(-4,-4),(0,-13),(4,-4)]:
   points.append((14+x*math.cos(a)-y*math.sin(a),14+x*math.sin(a)+y*math.cos(a)))
  poly(d,points,'5aeef0')
 d.ellipse((11,11,17,17),fill=RGB('eeffff'))
 im.save(P/'shuriken.png')

def projectile():
 for c,name in [('ff7588','proyectil_rojo'),('f9bf5c','proyectil_dorado'),('80c7ff','proyectil_azul')]:
  im=Image.new('RGBA',(24,24));d=ImageDraw.Draw(im)
  d.ellipse((2,2,21,21),fill=(*RGB(c),65))
  d.ellipse((6,6,17,17),fill=RGB(c));d.ellipse((9,9,14,14),fill=(255,255,255,235))
  im.save(P/f'{name}.png')

for i in range(4):backdrop(i,2084+i*431)
for i in range(6):draw_ninja(i)
for typ in range(3):
 for frame in range(2):draw_enemy(typ,frame)
for phase in range(3):
 for frame in range(2):draw_boss(phase,frame)
shuriken();projectile()
print('Generated',len(list(P.glob('*.png'))),'art resources',sum(f.stat().st_size for f in P.glob('*.png')),'bytes')
