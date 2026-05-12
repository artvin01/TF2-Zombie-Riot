# Parse all items, weapons and their paps.
import util, vdf, os, subprocess, json, f3d
from modules.gamedata import items_game, modelmapping, strings_english

# Patch pyassimp to prevent null pointer error
if os.path.isdir("venv/lib/python3.14/site-packages/pyassimp/"):
    util.write("venv/lib/python3.14/site-packages/pyassimp/core.py", util.read("venv/lib/python3.14/site-packages/pyassimp/core.py").replace("""else:
                        setattr(target, name, [obj[i] for i in range(length)])""","""elif obj:
                        setattr(target, name, [obj[i] for i in range(length)])"""))
import pyassimp

CFG_WEAPONS = vdf.loads(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/weapons.cfg"))["Weapons"]

"""
TODO
[ ] Tooltip CSS rework as to fit the attributes
[ ] Fix: When searching for weapon kit, its weapons may not be shown if the name differs from the kit name
"""

# https://github.com/f3d-app/f3d/blob/master/examples/libf3d/python/offscreen-thumbnail/offscreen_thumbnail.py
f3d.Engine.autoload_plugins()
eng = f3d.Engine.create(True)
eng.window.size = 256,256
opt = eng.options

# No UI overlays in thumbnails
opt["ui.axis"] = False
opt["ui.fps"] = False
opt["ui.filename"] = False
opt["ui.metadata"] = False
opt["ui.console"] = False
opt["ui.cheatsheet"] = False
opt["render.grid.enable"] = False

# Slightly stronger lighting so assets read well at small sizes
opt["render.light.intensity"] = 1.2
opt["model.color.rgb"] = (.7,.7,.7)

# Post-processing: AA + AO for better thumbnails
opt["render.effect.antialiasing.enable"] = True
opt["render.effect.antialiasing.mode"] = "ssaa"
opt["render.effect.ambient_occlusion"] = True

def generate_weapon_icon(weapon_data, weapon_name, pure_filename, prefix="", bodygroup_prefix=""):
    util.debug(f"[weaponicon] {weapon_name}, {pure_filename}, {prefix if prefix else "noprefix"}","weaponicon","OKBLUE")

    # Get SMD file
    if f"{bodygroup_prefix}weapon_bodygroup" in weapon_data: mdl_bodygroup = weapon_data[f"{bodygroup_prefix}weapon_bodygroup"]
    else: mdl_bodygroup = "1"
    smd_path = f"{prefix}decompiled/{json.loads(util.read(f"{prefix}decompiled/{pure_filename}.json"))[mdl_bodygroup]}" # TODO cache

    if smd_path == "decompiled/w_crossbow_reference.smd": return # TODO see below

    util.debug(f"[weaponicon] {"✓" if os.path.isfile(smd_path) else "✗"} {smd_path} : {mdl_bodygroup}","weaponicon","OKBLUE")

    if os.path.isfile(f"gh-pages/{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"): # Pre-generated icons
        util.debug(f"[weaponicon]     {prefix}icons/{pure_filename}_{mdl_bodygroup}.png is cached!","weaponicon","OKCYAN")
        return f'<div class="secondary notice"><img src="static/info.svg">Experimental weapon preview</div><img class="weapon_preview" src="{prefix}icons/{pure_filename}_{mdl_bodygroup}.png">'

    # Convert SMD => OBJ
    # TODO pyassimp just HATES this model and I do not know why
    # [LOG] [weaponicon] Crossbow, custom_weaponry_1_57, noprefix
    # [LOG] [weaponicon] ✓ decompiled/w_crossbow_reference.smd : 4
    # pyassimp.errors.AssimpError: Could not import file!
    with pyassimp.load(smd_path) as assimp_scene: # <class 'contextlib._GeneratorContextManager'> must have storage info
        pyassimp.export(assimp_scene, f"{prefix}decompiled/{pure_filename}_{mdl_bodygroup}.obj", "obj")

    # Generate thumbnail using F3D
    util.log(f"Generating thumbnail of {prefix}decompiled/{pure_filename}_{mdl_bodygroup}.obj")
    eng.scene.clear()
    eng.scene.add(f"{prefix}decompiled/{pure_filename}_{mdl_bodygroup}.obj")
    eng.window.render_to_image(no_background=True).save(f"./gh-pages/{prefix}icons/{pure_filename}_{mdl_bodygroup}.png")
    return f'<div class="secondary notice"><img src="static/info.svg">Experimental weapon preview</div><img class="weapon_preview" src="{prefix}icons/{pure_filename}_{mdl_bodygroup}.png">'

class Weapon:
    def __init__(self, weapon_name, weapon_data):
        self._weapon_name,self.name=weapon_name,weapon_name
        self._weapon_data=weapon_data

        if "tags" in weapon_data:
            self.taglist = weapon_data["tags"].split(";")
            if "," in weapon_data["tags"]: self.taglist = weapon_data["tags"].split(",") # crystal shard uses commas instead of semicolons. blame artvin XXX: Source repo issue
            self.tags = " ".join(f"#{tag}" for tag in self.taglist if tag != "" and len(tag)>2)
        else: self.tags = ""; self.taglist=[]

        if "author" in weapon_data: self.author = f"By {weapon_data["author"]}"
        else: self.author = ""

        self.cost = weapon_data["cost"]
        if self.cost=="0": self.cost="Free"

        if "desc" in weapon_data: 
            k = weapon_data["desc"]
            self.description = util.get_key(k)
            self.description = self.description.replace("\\n","\n").replace("\n-","\n - ")
            if self.description.startswith("-"): self.description=" - "+self.description[1:]
        else: self.description = ""

        if "level" in weapon_data:
            self.lvl = f"<div>Level: {weapon_data["level"]}</div>"
        else:
            self.lvl = ""
        
        self.attributes = []
        if "attributes" in weapon_data:
            _attrs=weapon_data["attributes"].split(";")
            try:
                for index, value in zip(_attrs[0::2],_attrs[1::2],strict=True):
                    if index.strip() in items_game["attributes"]: # TODO there are some custom attributes, gotta make manual entries for those to be included
                        attribute_data = items_game["attributes"][index.strip()]
                        if "hidden" in attribute_data: 
                            if attribute_data["hidden"]=="1": continue
                        if "description_string" in attribute_data:
                            desc_str = attribute_data["description_string"].strip("#")
                            val_str = str(int(float(value)*100))
                            if desc_str in strings_english:
                                desc = strings_english[desc_str].replace("%s1", val_str)
                                if val_str.startswith("-"):
                                    desc=desc.strip("+") # Prevent attributes showing up as "+-200% [attribute desc]"
                            else:
                                desc = f"{val_str}% {desc_str}"
                            self.attributes.append(desc)
            except ValueError:
                pass # The Trash Cannon

        # If weapon uses custom model, fetch source SMD file from bodygroup
        self.icon = ""
        if "model_weapon_override" in weapon_data:
            if weapon_data["model_weapon_override"]!="models/empty.mdl":
                pure_filename = weapon_data["model_weapon_override"].split("/")[-1].split(".")[0]
                if os.path.isfile(f"decompiled/{pure_filename}.json"): # only generate icon if decompiled data exists
                    self.icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename)
                elif os.path.isfile(f"tf_decompiled/{pure_filename}.json"): # only generate icon if decompiled data exists
                    self.icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename, prefix="tf_")
                else:
                    util.log(f"[Weapon] Skipping thumbnail generation: bodygroup mappings missing for {pure_filename}","WARNING")
        elif "classname" in weapon_data:
            path = modelmapping[weapon_data["classname"]]
            pure_filename = path.split("/")[-1].split(".")[0]
            self.icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename,prefix="tf_")


    def to_html(self,wcfghidden=True,wtags=None):
        hidden_str = "<i>Hidden</i>\n" if "hidden" in self._weapon_data else ""
        context = {
            "name": self.name,
            "data_item": util.fill_template(
                util.read("templates/items/item.html"), 
                {
                    "tags": self.tags,
                    "author": util.apply_morecolors(self.author),
                    "cost": self.cost,
                    "desc": f"{hidden_str}{self.lvl}{util.divfornewline(self.description)}{self.icon}{util.divfornewline("\n".join(self.attributes))}",
                }    
            ),
            "wtags": wtags or self.tags,
            "wcfghidden": "weapon_cfghidden hidden" if ("hidden" in self._weapon_data) and wcfghidden else ""
        }
        return util.fill_template(util.read("templates/items/item_preview.html"), context)
    

    def paps_to_html(self,wcfghidden=True,wtags=None):
        context = {
            "wtags": wtags or self.tags,
            "wcfghidden": "weapon_cfghidden" if ("hidden" in self._weapon_data) and wcfghidden else "" # paps are hidden by default
        }
        return util.fill_template(self.get_paps_html(), context)
    

    def get_paps_html(self):
        """
        pap_#_pappaths define how many paps you can choose from below ("2" paths on "PaP 1" allows you to choose between "PaP 2" and "PaP 3")
        pap_#_papskip Skips a number of paps to choose ("1" skip on "PaP 1" allows you to choose "PaP 3" instead)
        """
        pap_idx = 0
        pap_html = ""
        def item_block(parent_pap,idx,html,depth):
            html += f"<div class=\"weapon_pap wcfghidden hidden\" weapon_tags=\"wtags\" style=\"margin-left: {(depth+1)*10}px;\">\n"
            for i in range(int(parent_pap.pappaths)):
                idx += 1
                if int(parent_pap.pappaths)>1:
                    html += f"<i>Path {i+1}</i>\n"
                pd = WeaponPap(self._weapon_name,self._weapon_data,idx,depth)
                if pd.valid:
                    html += pd.to_html()
                    if pd.pappaths!="0": html = item_block(pd, idx+int(pd.papskip), html, depth+1)
            html += "</div>\n"
            return html
        
        if "pappaths" in self._weapon_data: init_pap_paths = self._weapon_data["pappaths"]
        else: init_pap_paths = 1
        pap_html = item_block(WeaponPap_Dummy(init_pap_paths), pap_idx, pap_html, 0)
        if len(pap_html)>0:
            pap_html += "\n"
        return pap_html
    

    def add_global_tags(self, gtags):
        for tag in self.taglist:
            if tag.capitalize() not in gtags and tag not in gtags and len(tag)>2: gtags.append(tag)
        return gtags

class WeaponPap:
    def __init__(self, weapon_name, weapon_data, idx, depth):
        self.depth = depth
        pap_key = f"pap_{idx}_"
        key_desc = pap_key+"desc"
        util.debug(f"Parsing {weapon_name} {pap_key}","weaponpap")
        if key_desc in weapon_data:
            key_customname = pap_key + "custom_name"
            if key_customname in weapon_data: self.name = weapon_data[key_customname]
            else: self.name = weapon_name
            
            self.description = weapon_data[key_desc]

            self.cost = weapon_data[pap_key+"cost"]

            if pap_key+"tags" in weapon_data: self.tags = " ".join(f"#{tag}" for tag in weapon_data[pap_key+"tags"].split(";") if tag != "")
            else: self.tags = ""

            # There has got to a better way to do this
            key_papskip = pap_key+"papskip"
            if key_papskip in weapon_data: self.papskip = weapon_data[key_papskip]
            else: self.papskip = "0"

            key_pappaths = pap_key+"pappaths"
            if key_pappaths in weapon_data: self.pappaths = weapon_data[key_pappaths]
            else: self.pappaths = "1"

            key_extra_desc = pap_key+"extra_desc"
            if key_extra_desc in weapon_data: self.extra_desc = weapon_data[key_extra_desc]
            else: self.extra_desc = ""

            # If weapon uses custom model, fetch source SMD file from bodygroup
            self.icon = ""
            if f"{pap_key}model_weapon_override" in weapon_data:
                if weapon_data[f"{pap_key}model_weapon_override"]!="models/empty.mdl":
                    pure_filename = weapon_data[f"{pap_key}model_weapon_override"].split("/")[-1].split(".")[0]
                    if os.path.isfile(f"decompiled/{pure_filename}.json"): # only generate icon if decompiled data exists
                        self.icon = generate_weapon_icon(weapon_data,self.name,pure_filename, bodygroup_prefix=pap_key)
                    elif os.path.isfile(f"tf_decompiled/{pure_filename}.json"): # only generate icon if decompiled data exists
                        self.icon = generate_weapon_icon(weapon_data,self.name,pure_filename, prefix="tf_", bodygroup_prefix=pap_key)
                    else:
                        util.log(f"[WeaponPap] Skipping thumbnail generation: bodygroup mappings missing for {pure_filename}","WARNING")
            elif f"{pap_key}classname" in weapon_data:
                path = modelmapping[weapon_data[f"{pap_key}classname"]]
                pure_filename = path.split("/")[-1].split(".")[0]
                self.icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename,prefix="tf_",bodygroup_prefix=pap_key)

        self.valid = key_desc in weapon_data

    def to_link(self):
        return f"{" "*self.depth}{self.name}  \n"
    
    def to_html_preview(self):
        if len(self.tags)>0: tags = f"{self.tags}"
        else: tags = ""
        extra_desc = self.extra_desc.replace("\\n","\n") if len(self.extra_desc) > 0 else ""
        desc = util.get_key(self.description).replace("\\n","\n")

        context = {
            "name": self.name,
            "tags": tags,
            "author": "",
            "cost": f"{self.cost}",
            "desc": f"{util.divfornewline(desc)}{util.divfornewline(extra_desc)}{self.icon}",
        }
        return util.fill_template(util.read("templates/items/item.html"), context)
    
    def to_html(self):
        context = { # wtags left out intentionally, it is replaced later
            "name": self.name,
            "data_item": self.to_html_preview()
        }
        return util.fill_template(util.read("templates/items/item_preview.html"), context)

class WeaponPap_Dummy:
    def __init__(self, init_pap_paths):
        self.papskip = "0"
        self.pappaths = init_pap_paths
    
class GenericItem:
    def __init__(self, item_data):
        self.is_item_category="enhanceweapon_click" not in item_data and "cost" not in item_data
        self.is_weapon=(("desc" in item_data) or ("author" in item_data)) and not "weaponkit" in item_data
        self.is_weapon_kit="weaponkit" in item_data
        self.is_trophy="desc" in item_data and "visual_desc_only" in item_data
        self.is_category="author" not in item_data and "filter" in item_data and "whiteout" not in item_data
        self.is_text="whiteout" in item_data

def parse():
    util.log("Parsing Weapon List...")

    HTML_WEAPON = ""
    def item_block(key, data, depth, html, tags):
        if "hidden" not in data:
            depth += 1
            contents=""
            for item in data:
                item_data = data[item]
                itm = GenericItem(item_data)
                if itm.is_trophy:
                    """
                    "Magia Wings [???]"
                        {
                            "desc"		"Oh how the Stars shine upon those who rule Ruina..." (can be a desc key!)
                            "cost"		"0"
                            "textstore"	"Magia Wings [???]"
                            "visual_desc_only"	"0"
                            "attributes"	"2 ; 1.0"
                            "index"		"2" //0 = primary, 1 = secondary, 2 = melee, 3 = Body, 4 = mage?
                            "slot"		"11" // 11 is cosmetics
                        }
                    """
                    context = {
                        "name": util.get_key(item, silent=True),
                        "data_item": util.divfornewline(util.get_key(item_data["desc"], silent=True)),
                        "wtags": "",
                        "wcfghidden": ""
                    }
                    contents += util.fill_template(util.read("templates/items/item_preview.html"), context)
                elif itm.is_weapon:
                    wep = Weapon(item,item_data)
                    tags=wep.add_global_tags(tags)
                    contents += wep.to_html()
                    contents += wep.paps_to_html()
                elif itm.is_weapon_kit:
                    kit = Weapon(item,item_data)
                    tags=kit.add_global_tags(tags)
                    contents += kit.to_html(wcfghidden=False)

                    # kit items (has pap)
                    def _kitweps():
                        h=""
                        for k,v in item_data.items():
                            if GenericItem(v).is_weapon:
                                kitwep = Weapon(k,v)
                                h += kitwep.to_html(wcfghidden=False, wtags=kit.tags)
                                h += kitwep.paps_to_html(wcfghidden=False, wtags=kit.tags)
                        return h
                    contents += f'<div style="margin-left: 10px;">\n{_kitweps()}</div>\n'
                elif item[0].isupper() and itm.is_category or "Perks" in item: # unneeded data is always lowercase...
                    contents, tags = item_block(item, item_data, depth, contents, tags)
                elif "Trophies" == item: # Item
                    contents, tags = item_block(item, item_data, depth, contents, tags)
                elif itm.is_text: # Text shown in menu
                    contents += f"{item}\n"
            html += f'<details>\n    <summary class="noselect">{key}</summary>{contents}</details>\n'
        return html, tags


    tags = []
    for item_category in CFG_WEAPONS:
        if GenericItem(CFG_WEAPONS[item_category]).is_item_category:
            HTML_WEAPON, tags = item_block(item_category,CFG_WEAPONS[item_category],0, HTML_WEAPON, tags)
    
    tags_html = "".join([f"<div class=\"btn\" tabindex=\"0\" onclick=\"filter_set_tag('{tag}');\">#{tag}</div>" for tag in tags])
    context = {
        "gtags": tags_html,
        "itemdata": HTML_WEAPON
    }
    util.write("gh-pages/items.html", util.fill_template(util.read("templates/items/items.html"), context))