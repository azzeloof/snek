from PIL import Image, ImageOps

threshold = 127

im = Image.open('splash.png')
f = open('splash.bin', 'w')
pix = im.load(),
print(im.size)
print(min(im.getpixel((12, 12))))
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