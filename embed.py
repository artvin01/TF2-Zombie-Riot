from PIL import Image, ImageDraw, ImageFont
import math
from time import sleep
from itertools import tee
from re import sub


color = {
    "bg_dark": (24, 26, 27),
    "bg_light": (230,234,221),
    "text_dark": (204,200,193),
    "link_dark": (149,187,212),
    "deep-space-blue": (21,50,67)
}

font = {
    "Oswald": ImageFont.truetype('gh-pages/static/Oswald-VariableFont_wght.ttf', 32),
    "Oswald Small": ImageFont.truetype('gh-pages/static/Oswald-VariableFont_wght.ttf', 16),
    "Noto Sans": ImageFont.truetype('gh-pages/static/NotoSans-VariableFont_wdth,wght.ttf', 16),
}

img_cache = {}

WIDTH = 1024
HEIGHT = 512

ICON_SIZE = 50
ICON_PADDING = 6
ICON_INNER_PADDING = 2


# TODO show support npcs separately
def generate_waveset_embed(filename, title, wave, wave_max, entries):

    global ICON_SIZE, ICON_PADDING, ICON_INNER_PADDING
    ICON_SIZE = 50
    ICON_INNER_PADDING = 5

    bar_y = 125
    bar_height = 15
    bar_padding = 25
    bar_width = WIDTH-((bar_padding+2)*2)

    npc_list_chunks = chunks([entry for entry in entries if entry["type"] == "npc"], math.floor((WIDTH-60)/(ICON_SIZE+ICON_PADDING)))

    dx = 0
    dy = bar_y+bar_height+35

    npc_list_chunks, chunklen = tee(npc_list_chunks) # copy generator as not to break following code
    nlen = len(list(chunklen)) 
    enemy_height = ICON_SIZE+ICON_PADDING+ICON_SIZE/2
    HEIGHT = dy+math.ceil(enemy_height * nlen)
    
    img = Image.new(mode="RGB", size=(WIDTH, HEIGHT))
    drawable = ImageDraw.Draw(img)

    drawable.rectangle([(0,0),(WIDTH,HEIGHT)], color["bg_dark"])
    # https://pillow.readthedocs.io/en/stable/deprecations.html#font-size-and-offset-methods
    draw_text_centered(drawable, (WIDTH/2, 10), title, color["text_dark"], font["Oswald"])
    draw_text_centered(drawable, (WIDTH/2, 65), f"WAVE {wave} / {wave_max}", color["text_dark"], font["Oswald Small"])

    drawable.rounded_rectangle([(bar_padding,bar_y), (WIDTH-bar_padding,bar_y+bar_height)], 4, color["bg_light"], outline=color["deep-space-blue"])
    progress = (wave/wave_max)*bar_width
    drawable.rounded_rectangle([(bar_padding+2,bar_y+2), (bar_padding+2+progress,(bar_y+bar_height)-2)], 4, color["link_dark"], corners=(True,True,True,True) if wave == wave_max else (True, False, False, True))


    for row in npc_list_chunks:
        row_w = (ICON_SIZE+ICON_PADDING)*len(row)
        dx = (WIDTH/2) - (row_w/2) + (ICON_SIZE+ICON_PADDING)/2
        for npc in row:
            draw_npc(drawable, img, (dx,dy), npc)
            dx += ICON_SIZE+ICON_PADDING
        dy += ICON_SIZE+ICON_PADDING+ICON_SIZE/2
    
    img.save(f"gh-pages/embed/{filename}.jpg")


def draw_text_centered(drawable, pos, text, fill, font):
    text=sub(r'[^a-zA-Z0-9 /]', '', text)
    left, _, right, _ = font.getbbox(text)
    width = right - left
    drawable.text((pos[0]-(width/2),pos[1]), text, fill=fill,font=font)

def draw_npc(drawable, img, pos, npc):
    left,top = pos[0]-(ICON_SIZE/2), pos[1]-(ICON_SIZE/2)
    drawable.rounded_rectangle([(left,top), (left+ICON_SIZE,top+ICON_SIZE)], 4, color["bg_light"])
    icon_filepath = npc["img"][10:-11]
    if icon_filepath.startswith("./"): # only missing.png paths start with ./
        icon_filepath = icon_filepath.replace("./","gh-pages/")
    icon = Image.open(icon_filepath, 'r')
    s = ICON_SIZE-(ICON_INNER_PADDING*2)
    icon = icon.resize((s,s))
    if "missing" in icon_filepath:
        img.paste(icon, (math.floor(left+ICON_INNER_PADDING),math.floor(top+ICON_INNER_PADDING)))
    else:
        img.paste(icon, (math.floor(left+ICON_INNER_PADDING),math.floor(top+ICON_INNER_PADDING)), icon)

    draw_text_centered(drawable, (pos[0], pos[1]+ICON_SIZE/2), npc["count"], color["text_dark"], font["Noto Sans"])
    

# Source - https://stackoverflow.com/a/312464
def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]


#generate_waveset_embed("infectedsilvester.jpg", "Infected Silvester", 29, 40, {})