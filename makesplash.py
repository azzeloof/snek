"""
makesplash.py
snek
Adam Zeloof
11/27/2020

Take a 640x480 PNG and spit out a file with binary pixels

"""
from PIL import Image, ImageOps

threshold = 127

im = Image.open('splash.png')
f = open('splash.bin', 'w')
pix = im.load(),
im = ImageOps.mirror(im)

for j in range(0, im.size[1]):
    for i in range (0, im.size[0]):
        val = min(im.getpixel((i,j)))
        if val > threshold:
            f.write('0')
        else:
            f.write('1')
    f.write('\n')

f.close()
