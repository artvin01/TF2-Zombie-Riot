# Parse all items, weapons and their paps.
import util, vdf, os, subprocess, json, f3d
from modules.gamedata import items_game, modelmapping, strings_english
from collections import defaultdict

# THUMBNAIL ========================================================================
# Patch pyassimp to prevent null pointer error
if os.path.isdir("venv/lib/python3.14/site-packages/pyassimp/"):
    util.write("venv/lib/python3.14/site-packages/pyassimp/core.py", util.read("venv/lib/python3.14/site-packages/pyassimp/core.py").replace("""else:
                        setattr(target, name, [obj[i] for i in range(length)])""","""elif obj:
                        setattr(target, name, [obj[i] for i in range(length)])"""))
import pyassimp


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

BODYGROUP_MAPPINGS={} # file cache to prevent multiple reads
def generate_weapon_icon(weapon_data, weapon_name, pure_filename, prefix="", bodygroup_prefix=""):
    util.debug(f"[weaponicon] {weapon_name}, {pure_filename}, {prefix if prefix else "noprefix"}","weaponicon","OKBLUE")

    # Get SMD file
    if f"{bodygroup_prefix}weapon_bodygroup" in weapon_data: mdl_bodygroup = weapon_data[f"{bodygroup_prefix}weapon_bodygroup"]
    else: mdl_bodygroup = "1"

    if (bodygroupmap_path:=f"{prefix}decompiled/{pure_filename}.json") not in BODYGROUP_MAPPINGS: BODYGROUP_MAPPINGS[bodygroupmap_path] = json.loads(util.read(bodygroupmap_path))
    smd_path = f"{prefix}decompiled/{BODYGROUP_MAPPINGS[bodygroupmap_path][mdl_bodygroup]}"

    if smd_path == "decompiled/w_crossbow_reference.smd": return "" # TODO see below

    util.debug(f"[weaponicon] {"✓" if os.path.isfile(smd_path) else "✗"} {smd_path} : {mdl_bodygroup}","weaponicon","OKBLUE")

    if os.path.isfile(f"gh-pages/{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"): # Pre-generated icons
        util.debug(f"[weaponicon]     {prefix}icons/{pure_filename}_{mdl_bodygroup}.png is cached!","weaponicon","OKCYAN")
        return f"{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"

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
    eng.interactor.trigger_command("set_camera isometric")
    eng.window.render_to_image(no_background=True).save(f"./gh-pages/{prefix}icons/{pure_filename}_{mdl_bodygroup}.png")
    return f"{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"

# CONFIG ========================================================================
CFG_WEAPONS = vdf.loads(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/weapons.cfg"))["Weapons"]
# Item blacklist for hidden items that aren't indicated as hidden
from ruamel.yaml import YAML
yaml=YAML(typ='safe')
with open("./config/item_blacklist.yml",'r') as file:
    ITEM_BLACKLIST = yaml.load(file)

# MAIN ========================================================================
class Weapon:
    def __init__(self, weapon_name, weapon_data):
        self._weapon_name,self.name=weapon_name,weapon_name
        self._weapon_data=weapon_data
        self.weapon_id = util.id_from_str(weapon_name)

        if "tags" in weapon_data:
            self.taglist = weapon_data["tags"].split(";")
            if "," in weapon_data["tags"]: self.taglist = weapon_data["tags"].split(",") # crystal shard uses commas instead of semicolons. blame artvin XXX: Source repo issue
            self.tags = " ".join(f"#{tag}" for tag in self.taglist if tag != "" and len(tag)>2)
        else: self.tags = ""; self.taglist=[]

        if "author" in weapon_data: self.author = f"By {weapon_data["author"]}"
        else: self.author = ""

        self.cost = weapon_data["cost"]
        if self.cost=="0": self.cost="Free"
        else: self.cost = f"${self.cost}"

        if "desc" in weapon_data: 
            k = weapon_data["desc"]
            self.description = util.get_key(k)
            self.description = self.description.replace("\\n","\n").replace("\n-","\n - ")
            if self.description.startswith("-"): self.description=" - "+self.description[1:]
        else: self.description = ""

        if "level" in weapon_data:
            self.lvl = weapon_data["level"]
        else:
            self.lvl = ""
        
        self.attributes = defaultdict(list)
        if "attributes" in weapon_data:
            _attrs=weapon_data["attributes"].split(";")
            for index, value in zip(_attrs[0::2],_attrs[1::2],strict=True):
                if index.strip() in items_game["attributes"]: # TODO there are some custom attributes, gotta make manual entries for those to be included
                    attribute_data = items_game["attributes"][index.strip()]
                    if "hidden" in attribute_data: 
                        if attribute_data["hidden"]=="1": continue
                    if "description_string" in attribute_data:
                        desc_str = attribute_data["description_string"].strip("#")
                        attr_type = attribute_data["effect_type"]
                        # some of these calculations may be incorrect, it seems like it's impossible to keep the positive/negative types correct without hardcoding
                        if attribute_data["description_format"] == "value_is_percentage":
                            val_str = str(int((float(value)*100)-100))
                        elif attribute_data["description_format"] == "value_is_inverted_percentage":
                            val_str = str(-int((float(value)*100)-100))
                        elif attribute_data["description_format"] == "value_is_additive_percentage":
                            val_str = str(int(float(value)*100))
                        elif attribute_data["description_format"] == "value_is_additive":
                            val_str = value
                        val_str=val_str.strip()

                        if val_str != "0":
                            if desc_str in strings_english:
                                desc_pre = strings_english[desc_str]
                                if val_str.startswith("-"):
                                    if desc_pre.startswith("+") or desc_pre.startswith("-"): desc_pre=desc_pre[1:] # Prevent attributes showing up as "+-200% [attribute desc]"
                                desc = desc_pre.replace("%s1", val_str)
                            else:
                                desc = f"{val_str} {desc_str}"
                            self.attributes[attr_type].append(desc)

        # If weapon uses custom model, fetch source SMD file from bodygroup
        self.icon = ""
        if weapon_name == "Wrench":
            path = "models/weapons/c_models/c_wrench/c_wrench.mdl"
            pure_filename = path.split("/")[-1].split(".")[0]
            self.icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename,prefix="tf_")
        elif "model_weapon_override" in weapon_data:
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
        
        self.parse_enhancements()


    def parse_enhancements(self):
        """
        pap_#_pappaths define how many paps you can choose from below ("2" paths on "PaP 1" allows you to choose between "PaP 2" and "PaP 3")
        pap_#_papskip Skips a number of paps to choose ("1" skip on "PaP 1" allows you to choose "PaP 3" instead)
        """
        self.subweapons = {
            "name": "Weapon Enhancements",
            "items": []
        }
        pap_idx = 0
        pap_html = ""
        def item_block(parent_pap,idx,output):
            for i in range(int(parent_pap.pappaths)):
                idx += 1
                #if int(parent_pap.pappaths)>1:
                #    output += f"<i>Path {i+1}</i>\n"
                pd = WeaponPap(self._weapon_name,self._weapon_data,idx)
                if pd.valid:
                    if pd.pappaths!="0": pd.subweapons = item_block(pd, idx+int(pd.papskip), defaultdict(list))
                    output["items"].append(pd)
            return output
        
        init_pap_paths = defaultdict(int,self._weapon_data)["pappaths"] or 1
        self.subweapons["items"] = item_block(WeaponPap_Dummy(init_pap_paths), pap_idx, defaultdict(list))["items"]
        if len(self.subweapons["items"])==0:
            self.subweapons = {}

    def add_global_tags(self):
        for tag in self.taglist:
            if tag.capitalize() not in GLOBAL_TAGS and tag not in GLOBAL_TAGS and len(tag)>2: GLOBAL_TAGS.append(tag)
    
    def __json__(self):
        return {
            "type": getattr(self,"type","weapon"),
            "tags": self.tags.split(),
            "name": self.name,
            "wid": self.weapon_id,
            "description": self.description,
            "author": self.author, # TODO apply morecolors on js side
            "lvl": self.lvl,
            "cost": self.cost,
            "is_hidden": defaultdict(str,self._weapon_data)["hidden"]=="1",
            "icon": self.icon,
            "attributes": self.attributes,
            "subweapons": getattr(self, "subweapons", {}) # kit weps, enhancements
        }

class WeaponPap:
    def __init__(self, weapon_name, weapon_data, idx):
        self._weapon_name,self.name=weapon_name,weapon_name
        self._weapon_data=weapon_data
        self._weapon_data_df = defaultdict(str,weapon_data)
        # TODO reliable subweapon id generation
        

        pap_key = f"pap_{idx}_"
        key_desc = pap_key+"desc"
        util.debug(f"Parsing {weapon_name} {pap_key}","weaponpap")
        if key_desc in weapon_data:
            if pap_key+"tags" in weapon_data: self.tags = " ".join(f"#{tag}" for tag in weapon_data[pap_key+"tags"].split(";") if tag != "")
            else: self.tags = ""

            self.cost = f"${weapon_data[pap_key+"cost"]}"

            key_customname = pap_key + "custom_name"
            if key_customname in weapon_data: self.name = weapon_data[key_customname]
            else: self.name = weapon_name
            
            self.description = util.get_key(weapon_data[key_desc]).replace("\\n","\n")

            # TODO unified function
            self.attributes = defaultdict(list)
            if f"{pap_key}attributes" in weapon_data:
                _attrs=weapon_data[f"{pap_key}attributes"].split(";")
                for index, value in zip(_attrs[0::2],_attrs[1::2],strict=True):
                    if index.strip() in items_game["attributes"]: # TODO there are some custom attributes, gotta make manual entries for those to be included
                        attribute_data = items_game["attributes"][index.strip()]
                        if "hidden" in attribute_data: 
                            if attribute_data["hidden"]=="1": continue
                        if "description_string" in attribute_data:
                            desc_str = attribute_data["description_string"].strip("#")
                            attr_type = attribute_data["effect_type"]
                            # some of these calculations may be incorrect
                            if attribute_data["description_format"] == "value_is_percentage":
                                val_str = str(int((float(value)*100)-100))
                            elif attribute_data["description_format"] == "value_is_inverted_percentage":
                                val_str = str(-int((float(value)*100)-100))
                            elif attribute_data["description_format"] == "value_is_additive_percentage":
                                val_str = str(int(float(value)*100))
                            elif attribute_data["description_format"] == "value_is_additive":
                                val_str = value
                            val_str=val_str.strip()

                            if val_str != "0":
                                if desc_str in strings_english:
                                    desc_pre = strings_english[desc_str]
                                    if val_str.startswith("-"):
                                        if desc_pre.startswith("+") or desc_pre.startswith("-"): desc_pre=desc_pre[1:] # Prevent attributes showing up as "+-200% [attribute desc]"
                                    desc = desc_pre.replace("%s1", val_str)
                                else:
                                    desc = f"{val_str} {desc_str}"
                                self.attributes[attr_type].append(desc)

            self.papskip = self._weapon_data_df[f"{pap_key}papskip"] or "0"
            self.pappaths = self._weapon_data_df[f"{pap_key}pappaths"] or "1"
            self.extra_desc = self._weapon_data_df[f"{pap_key}extra_desc"].replace("\\n","\n")

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

    def __json__(self):
        return {
            "type": "weaponpap", # items.js directly shows nested subweapons if type=="weaponpap"
            "tags": self.tags.split(),
            "name": self.name,
            "description": self.description,
            #"author": self.author, # TODO apply morecolors on js side
            #"lvl": self.lvl,
            "cost": self.cost,
            #"is_hidden": defaultdict(str,self._weapon_data)["hidden"]=="1",
            "icon": self.icon,
            "attributes": self.attributes,
            "subweapons": getattr(self, "subweapons", {})
        }

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
        self.is_category="author" not in item_data and ("filter" in item_data or "nokit" in item_data) and "whiteout" not in item_data
        self.is_text="whiteout" in item_data

util.log("Parsing Weapon List...")

def item_block(key, data, output, type_override=None):
    if ("hidden" not in data):# or key=="Koshi's Goods":
        if key=="Koshi's Goods":
            output["$description"] = [
                "Only available in Freeplay."
            ]
        for item in data:
            item_data = data[item]
            itm = GenericItem(item_data)
            if item in ITEM_BLACKLIST: continue
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
                output["$items"].append({
                    "type": "trophy",
                    "name": util.get_key(item, silent=True),
                    "description": util.get_key(item_data["desc"], silent=True),
                    "wtags": "",
                    "wcfghidden": ""
                })
                #html += util.fill_template(util.read("templates/items/item_preview.html"), context)
            elif itm.is_weapon:
                wep = Weapon(item,item_data)
                if type_override: wep.type=type_override
                wep.add_global_tags()
                output["$items"].append(wep)
            elif itm.is_weapon_kit:
                kit = Weapon(item,item_data)
                if type_override: kit.type=type_override
                kit.add_global_tags()
                kit.subweapons = {
                    "name": "Kit Items",
                    "items": []
                }

                # kit items (has pap)
                for k,v in item_data.items():
                    if GenericItem(v).is_weapon:
                        kit.subweapons["items"].append(Weapon(k,v))
                
                output["$items"].append(kit)
            elif item[0].isupper() and itm.is_category or "Perks" in item: # unneeded data is always lowercase...
                prev_override = type_override
                if item == "Level Perks":
                    type_override = "perk"
                elif item == "Barracks Civilization":
                    type_override = "barrack"
                elif item == "Weapon Kits":
                    type_override = "weaponkit"
                output[item] = item_block(item, item_data, defaultdict(list),type_override)
                type_override = prev_override
            elif "Trophies" == item:
                output[item] = item_block(item, item_data, defaultdict(list))
            elif itm.is_text: # Text shown in menu
                output["$description"].append(item)
    return output

GLOBAL_TAGS = []
WEAPONSDATA = {}
type_override = None
for item_category in CFG_WEAPONS:
    if GenericItem(CFG_WEAPONS[item_category]).is_item_category:
        if item_category == "Upgrades":
            type_override = "upgrade"
        output = item_block(item_category, CFG_WEAPONS[item_category], defaultdict(list),type_override)
        type_override = None
        if output: # no empty categories
            WEAPONSDATA[item_category] = output

if not os.path.isdir("gh-pages/items"): subprocess.run(["mkdir", "gh-pages/items"]) # TODO unified dir for all .json data i.e. put skilltree and weapon json in one directory
util.write("gh-pages/items/items.json", json.dumps(WEAPONSDATA,indent=2))