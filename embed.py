from PIL import Image, ImageDraw, ImageFont
import math
from time import sleep
from itertools import tee
from re import sub
from collections import defaultdict


color = {
    "viewer_bg": (60,65,68),
    "bg_dark": (24, 26, 27),
    "bg_light": (230,234,221),
    "text_dark": (204,200,193),
    "link_dark": (149,187,212),
    "deep-space-blue": (21,50,67),
    "red_bg": (203,36,2), # miniboss, mission
    "blue_outline": (38,153,173)
}

font = {
    "Oswald": ImageFont.truetype('gh-pages/static/Oswald-VariableFont_wght.ttf', 32),
    "Oswald Small": ImageFont.truetype('gh-pages/static/Oswald-VariableFont_wght.ttf', 24),
    "Noto Sans": ImageFont.truetype('gh-pages/static/NotoSans-VariableFont_wdth,wght.ttf', 16),
}

img_cache = {}

WIDTH = 1024
HEIGHT = 512

ICON_SIZE = 50
ICON_PADDING = 8
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

    base_npc_list = [entry for entry in entries if (entry["type"] == "npc") and ("MVM_CLASS_FLAG_SUPPORT" not in entry["embed_extra_flags"]) and ("MVM_CLASS_FLAG_SUPPORT_LIMITED" not in entry["embed_extra_flags"]) and ("MVM_CLASS_FLAG_MISSION" not in entry["embed_extra_flags"])]
    support_npc_list = [entry for entry in entries if (entry["type"] == "npc") and (("MVM_CLASS_FLAG_SUPPORT" in entry["embed_extra_flags"]) or ("MVM_CLASS_FLAG_SUPPORT_LIMITED" in entry["embed_extra_flags"]) or ("MVM_CLASS_FLAG_MISSION" in entry["embed_extra_flags"]))]
    base_npc_list_chunks = chunks(base_npc_list, math.floor((WIDTH-60)/(ICON_SIZE+ICON_PADDING)))
    support_npc_list_chunks = chunks(support_npc_list, math.floor((WIDTH-60)/(ICON_SIZE+ICON_PADDING)))

    dx = 0
    dy = bar_y+bar_height+35

    base_npc_list_chunks, base_chunklen = tee(base_npc_list_chunks) # copy generator as not to break following code
    support_npc_list_chunks, support_chunklen = tee(support_npc_list_chunks) # copy generator as not to break following code
    base_nlen, support_nlen = len(list(base_chunklen)), len(list(support_chunklen)) 
    enemy_height = ICON_SIZE+ICON_PADDING+ICON_SIZE/2
    support_padding=100
    HEIGHT = dy+math.ceil(enemy_height * base_nlen)+math.ceil(enemy_height * support_nlen)+support_padding
    
    imgs = [Image.new(mode="RGB", size=(WIDTH, HEIGHT))]

    # check if entries have at least one npc with the mission flag (red flashing background requires 2 imgs => gif)
    entries_have_mission_flag = any(("MVM_CLASS_FLAG_MISSION" in defaultdict(str,entry_data)["embed_extra_flags"]) and (entry_data["type"]=="npc") for entry_data in entries)
    if entries_have_mission_flag: imgs.append(Image.new(mode="RGB", size=(WIDTH, HEIGHT)))

    drawables = [ImageDraw.Draw(img) for img in imgs]
    for idx, drawable in enumerate(drawables):
        img=imgs[idx]

        dx = 0
        dy = bar_y+bar_height+35

        drawable.rectangle([(0,0),(WIDTH,HEIGHT)], color["viewer_bg"])
        # https://pillow.readthedocs.io/en/stable/deprecations.html#font-size-and-offset-methods
        draw_text_centered(drawable, (WIDTH/2, 10), title, color["text_dark"], font["Oswald"])
        draw_text_centered(drawable, (WIDTH/2, 75), f"WAVE {wave} / {wave_max}", color["text_dark"], font["Oswald Small"])

        drawable.rounded_rectangle([(bar_padding,bar_y), (WIDTH-bar_padding,bar_y+bar_height)], 4, color["bg_light"], outline=color["deep-space-blue"])
        progress = (wave/wave_max)*bar_width
        drawable.rounded_rectangle([(bar_padding+2,bar_y+2), (bar_padding+2+progress,(bar_y+bar_height)-2)], 4, color["link_dark"], corners=(True,True,True,True) if wave == wave_max else (True, False, False, True))

        # draw bar separating support n base npcs
        if support_nlen>0:
            sbar_height = 3
            dy_alt = (dy+math.ceil(enemy_height * base_nlen)-(ICON_PADDING+(ICON_SIZE/2))) # calculate where cursor will be once base list finishes rendering
            sbar_y = dy_alt+25-(sbar_height/2)
            drawable.rounded_rectangle([(100,sbar_y), (WIDTH-100,sbar_y+sbar_height)], 4, color["bg_light"])
            draw_text_centered(drawable, (WIDTH/2, dy_alt+45), "SUPPORT", color["text_dark"], font["Oswald Small"])

    for i,row in enumerate(base_npc_list_chunks):
        row_w = (ICON_SIZE+ICON_PADDING)*len(row)
        dx = (WIDTH/2) - (row_w/2) + (ICON_SIZE+ICON_PADDING)/2
        for npc in row:
            [draw_npc(drawable, imgs, (dx,dy), npc, idx) for idx,drawable in enumerate(drawables)]
            dx += ICON_SIZE+ICON_PADDING
        
        if i == base_nlen-1:
            dy += ICON_SIZE # end directly at the bottom of the base icons list
        else:
            dy += ICON_SIZE+ICON_PADDING+ICON_SIZE/2
    
    if support_nlen>0:
        dx = 0    
        dy += 115
        for row in support_npc_list_chunks:
            row_w = (ICON_SIZE+ICON_PADDING)*len(row)
            dx = (WIDTH/2) - (row_w/2) + (ICON_SIZE+ICON_PADDING)/2
            for npc in row:
                [draw_npc(drawable, imgs, (dx,dy), npc, idx) for idx,drawable in enumerate(drawables)]
                dx += ICON_SIZE+ICON_PADDING
            dy += ICON_SIZE+ICON_PADDING+ICON_SIZE/2
        
    if len(imgs) == 1:
        imgs[0].save(f"gh-pages/embed/{filename}.gif")
    else:
        imgs[0].save(f"gh-pages/embed/{filename}.gif",
            save_all = True, append_images = imgs[1:], 
            optimize = False, duration = 500, loop=0)


def draw_text_centered(drawable, pos, text, fill, font):
    text=sub(r'[^a-zA-Z0-9 / \\-]', '', text)
    left, _, right, _ = font.getbbox(text)
    width = right - left
    drawable.text((pos[0]-(width/2),pos[1]), text, fill=fill,font=font)

def draw_npc(drawable, imgs, pos, npc, frame_idx=0):
    left,top = pos[0]-(ICON_SIZE/2), pos[1]-(ICON_SIZE/2)
    bg_color = color["bg_light"]
    if ("MVM_CLASS_FLAG_MINIBOSS" in npc["embed_extra_flags"]) or \
        (("MVM_CLASS_FLAG_MISSION" in npc["embed_extra_flags"]) and frame_idx==0):
        bg_color = color["red_bg"]
    if "MVM_CLASS_FLAG_ALWAYSCRIT" in npc["embed_extra_flags"]:
        drawable.rounded_rectangle([(left-2,top-2), (left+ICON_SIZE+2,top+ICON_SIZE+2)], 4, color["blue_outline"])
    drawable.rounded_rectangle([(left,top), (left+ICON_SIZE,top+ICON_SIZE)], 4, bg_color)
    icon_filepath = npc["img"][10:-11]
    if icon_filepath.startswith("./"): # only missing.png paths start with ./
        icon_filepath = icon_filepath.replace("./","gh-pages/")
    icon = Image.open(icon_filepath, 'r')
    s = ICON_SIZE-(ICON_INNER_PADDING*2)
    icon = icon.resize((s,s))
    if "missing" in icon_filepath:
        imgs[frame_idx].paste(icon, (math.floor(left+ICON_INNER_PADDING),math.floor(top+ICON_INNER_PADDING)))
    else:
        imgs[frame_idx].paste(icon, (math.floor(left+ICON_INNER_PADDING),math.floor(top+ICON_INNER_PADDING)), icon)

    draw_text_centered(drawable, (pos[0], pos[1]+ICON_SIZE/2), npc["count"], color["text_dark"], font["Noto Sans"])
    

# Source - https://stackoverflow.com/a/312464
def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]


#generate_waveset_embed("infectedsilvester.jpg", "Infected Silvester", 29, 40, {})