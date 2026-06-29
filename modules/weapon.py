# Parse all items, weapons and their paps.
import util
import vdf
import os
import json
import f3d
from modules.gamedata import items_game, modelmapping, strings_english
from collections import defaultdict
from ruamel.yaml import YAML
from typing import Any
type WeaponAttributes = dict[str,list[str]]
type WeaponData = dict[str,str]
type SubweaponList = dict[str,str | list[Weapon | WeaponPap]]

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
def generate_weapon_icon(weapon_data: WeaponData, weapon_name:str, pure_filename:str, prefix:str="", bodygroup_prefix:str="")->str:
    util.debug(f"[weaponicon] {weapon_name}, {pure_filename}, {prefix if prefix else "noprefix"}","weaponicon","OKBLUE")

    # Get SMD file
    mdl_bodygroup = "1" if (key_bodygroup:=f"{bodygroup_prefix}weapon_bodygroup") not in weapon_data else weapon_data[key_bodygroup]

    if (bodygroupmap_path:=f"{prefix}decompiled/{pure_filename}.json") not in BODYGROUP_MAPPINGS:
        BODYGROUP_MAPPINGS[bodygroupmap_path] = json.loads(util.read(bodygroupmap_path))
    smd_path = f"{prefix}decompiled/{BODYGROUP_MAPPINGS[bodygroupmap_path][mdl_bodygroup]}"

    # NOTE pyassimp crashes if a triangle has more than 1 material!
    if smd_path == "decompiled/w_crossbow_reference.smd":
        util.write(smd_path, util.read(smd_path).replace(" dirtmap",""))

    util.debug(f"[weaponicon] {"✓" if os.path.isfile(smd_path) else "✗"} {smd_path} : {mdl_bodygroup}","weaponicon","OKBLUE")

    if os.path.isfile(f"gh-pages/{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"): # Pre-generated icons
        util.debug(f"[weaponicon]     {prefix}icons/{pure_filename}_{mdl_bodygroup}.png is cached!","weaponicon","OKCYAN")
        return f"{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"

    # Convert SMD => OBJ
    #  # <class 'contextlib._GeneratorContextManager'> must have storage info
    with pyassimp.load(smd_path) as assimp_scene: # type: ignore[w]
        pyassimp.export(assimp_scene, f"{prefix}decompiled/{pure_filename}_{mdl_bodygroup}.obj", "obj") # type: ignore[w]

    # Generate thumbnail using F3D
    util.log(f"Generating thumbnail of {prefix}decompiled/{pure_filename}_{mdl_bodygroup}.obj")
    eng.scene.clear()
    eng.scene.add(f"{prefix}decompiled/{pure_filename}_{mdl_bodygroup}.obj") # type: ignore[w]
    eng.interactor.trigger_command("set_camera isometric")
    eng.window.render_to_image(no_background=True).save(f"./gh-pages/{prefix}icons/{pure_filename}_{mdl_bodygroup}.png")
    return f"{prefix}icons/{pure_filename}_{mdl_bodygroup}.png"

# Will not be implenenting custom attributes since attributes are already inaccurate. Won't bother adding more info to such a thing.
def shared_parse_weapon_attrs(weapon_data: WeaponData, pap_key:str="") -> WeaponAttributes:
    attributes: WeaponAttributes = defaultdict(list)
    if f"{pap_key}attributes" in weapon_data:
        _attrs=weapon_data[f"{pap_key}attributes"].split(";")
        for index, value in zip(_attrs[0::2],_attrs[1::2],strict=True):
            if index.strip() in items_game["attributes"]:
                attribute_data = items_game["attributes"][index.strip()]
                if "hidden" in attribute_data and attribute_data["hidden"]=="1":
                    continue
                if "description_string" in attribute_data:
                    desc_str = attribute_data["description_string"].strip("#")
                    attr_type = attribute_data["effect_type"]
                    # some of these calculations may be incorrect
                    val_str = ""
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
                                if desc_pre.startswith("+") or desc_pre.startswith("-"):
                                    desc_pre=desc_pre[1:] # Prevent attributes showing up as "+-200% [attribute desc]"
                            desc = desc_pre.replace("%s1", val_str)
                        else:
                            desc = f"{val_str} {desc_str}"
                        attributes[attr_type].append(desc)
    return attributes

def shared_parse_weapon_icon(weapon_data: WeaponData, weapon_name:str, pap_key:str="")->str:
    icon = ""
    if weapon_name == "Wrench":
        path = "models/weapons/c_models/c_wrench/c_wrench.mdl"
        pure_filename:str = path.split("/")[-1].split(".")[0]
        icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename,prefix="tf_")
    elif f"{pap_key}model_weapon_override" in weapon_data:
        if weapon_data[f"{pap_key}model_weapon_override"]!="models/empty.mdl":
            pure_filename = weapon_data[f"{pap_key}model_weapon_override"].split("/")[-1].split(".")[0]
            if os.path.isfile(f"decompiled/{pure_filename}.json"): # only generate icon if decompiled data exists
                icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename,bodygroup_prefix=pap_key)
            elif os.path.isfile(f"tf_decompiled/{pure_filename}.json"): # only generate icon if decompiled data exists
                icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename, prefix="tf_",bodygroup_prefix=pap_key)
            else:
                util.log(f"[Weapon] Skipping thumbnail generation: bodygroup mappings missing for {pure_filename}","WARNING")
    elif f"{pap_key}classname" in weapon_data:
        path = modelmapping[weapon_data[f"{pap_key}classname"]]
        pure_filename = path.split("/")[-1].split(".")[0]
        icon = generate_weapon_icon(weapon_data,weapon_name,pure_filename,prefix="tf_",bodygroup_prefix=pap_key)
    return icon

# CONFIG ========================================================================
CFG_WEAPONS: dict[str,Any] = vdf.loads(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/weapons.cfg"))["Weapons"] # type: ignore[w]
# Item blacklist for hidden items that aren't indicated as hidden
yaml=YAML(typ='safe')
with open("./config/item_blacklist.yml",'r') as file:
    ITEM_BLACKLIST = yaml.load(file) # type: ignore[w]
FACTION_MAPPINGS = {
    "1": "Expidonsa",
    "2": "Grunwald",
    "3": "Vesta",
    "4": "Psychic Warlord",
    "5": "Dweller"
}

# MAIN ========================================================================
g_tags:list[str] = []
class Weapon:
    def __init__(self, weapon_name: str, weapon_data: WeaponData):
        self.NAME:str=weapon_name
        self._WEAPON_DATA:WeaponData=weapon_data
        self.WEAPON_ID:str = util.id_from_str(weapon_name, 3) # override hexdigest because Ancestor Launcher and The Ritualist had same ids
        self.IS_HIDDEN:bool = weapon_data["hidden"]=="1" if "hidden" in weapon_data else False

        self.taglist:list[str] = [] if "tags" not in weapon_data else weapon_data["tags"].split(",") if "," in weapon_data["tags"] else weapon_data["tags"].split(";")
        self.tags:str = " ".join(f"{tag}" for tag in self.taglist if tag != "" and len(tag)>2) if "tags" in weapon_data else ""

        self.author:str = f"By {weapon_data["author"]}" if "author" in weapon_data else ""

        self.cost:str = "Free" if weapon_data["cost"]=="0" else f"${weapon_data["cost"]}"

        self.description:str = util.get_key(weapon_data["desc"]).replace("\\n","\n").replace("\n-","\n - ") if "desc" in weapon_data else ""

        self.lvl:str = weapon_data["level"] if "level" in weapon_data else ""

        self.faction:str = FACTION_MAPPINGS[weapon_data["weapon_faction"]] if "weapon_faction" in weapon_data else ""

        self.attributes: WeaponAttributes = shared_parse_weapon_attrs(weapon_data)

        self.icon:str = shared_parse_weapon_icon(weapon_data, weapon_name)

        self.parse_enhancements()


    def parse_enhancements(self):
        """
        pap_#_pappaths define how many paps you can choose from below ("2" paths on "PaP 1" allows you to choose between "PaP 2" and "PaP 3")
        pap_#_papskip Skips a number of paps to choose ("1" skip on "PaP 1" allows you to choose "PaP 3" instead)
        """
        self.subweapons: SubweaponList = {
            "name": "Weapon Enhancements",
            "items": []
        }
        pap_idx = 0
        def item_block(parent_pap: WeaponPap | WeaponPap_Dummy, idx:int, output: SubweaponList) -> dict[str,Any]:
            for _ in range(int(parent_pap.pappaths)):
                idx += 1
                pd = WeaponPap(self.NAME,self._WEAPON_DATA,idx)
                if pd.valid:
                    if pd.pappaths!="0":
                        pd.subweapons = item_block(pd, idx+int(pd.papskip), defaultdict(list))
                    output["items"].append(pd) # type: ignore[w]
            return output

        init_pap_paths = defaultdict(int,self._WEAPON_DATA)["pappaths"] or 1
        self.subweapons["items"] = item_block(WeaponPap_Dummy(init_pap_paths), pap_idx, defaultdict(list))["items"]
        if len(self.subweapons["items"])==0:
            self.subweapons = {}

    def add_global_tags(self):
        for tag in self.taglist:
            if tag.capitalize() not in g_tags and tag not in g_tags and len(tag)>2:
                g_tags.append(tag)

    def __json__(self) -> dict[str, Any]:
        return {
            "type": getattr(self,"type","weapon"),
            "tags": self.tags.split(),
            "name": self.NAME,
            "wid": self.WEAPON_ID,
            "description": self.description,
            "author": self.author,
            "lvl": self.lvl,
            "cost": self.cost,
            "rawcost": self._WEAPON_DATA["cost"],
            "is_hidden": self.IS_HIDDEN,
            "icon": self.icon,
            "faction": self.faction,
            "attributes": self.attributes,
            "subweapons": getattr(self, "subweapons", {}) # kit weps, enhancements
        }

class WeaponPap:
    def __init__(self, weapon_name:str, weapon_data: WeaponData, idx: int):
        self._WEAPON_DATA:WeaponData=weapon_data
        self._WEAPON_DATA_DF:WeaponData=defaultdict(str,weapon_data)

        pap_key = f"pap_{idx}_"
        key_desc = pap_key+"desc"
        util.debug(f"Parsing {weapon_name} {pap_key}","weaponpap")
        if key_desc in weapon_data:
            self.tags:str = "" if pap_key+"tags" not in weapon_data else " ".join(f"#{tag}" for tag in weapon_data[pap_key+"tags"].split(";") if tag != "")
            self.cost:str = f"${weapon_data[f"{pap_key}cost"]}"
            self.rawcost:str = weapon_data[f"{pap_key}cost"]

            self.NAME:str = weapon_name if pap_key + "custom_name" not in weapon_data else weapon_data[pap_key + "custom_name"]

            self.description:str = util.get_key(weapon_data[key_desc]).replace("\\n","\n")

            self.attributes: WeaponAttributes = shared_parse_weapon_attrs(weapon_data, pap_key)

            self.faction:str = FACTION_MAPPINGS[weapon_data[f"{pap_key}weapon_faction"]] if f"{pap_key}weapon_faction" in weapon_data else ""

            self.icon:str = shared_parse_weapon_icon(weapon_data, weapon_name, pap_key)

            self.papskip:str = self._WEAPON_DATA_DF[f"{pap_key}papskip"] or "0"
            self.pappaths:str = self._WEAPON_DATA_DF[f"{pap_key}pappaths"] or "1"
            self.extra_desc:str = self._WEAPON_DATA_DF[f"{pap_key}extra_desc"].replace("\\n","\n")

            self.subweapons: SubweaponList = {}

        self.valid:bool = key_desc in weapon_data

    def __json__(self) -> dict[str,Any]:
        return {
            "type": "weaponpap", # items.js directly shows nested subweapons if type=="weaponpap"
            "tags": self.tags.split(),
            "name": self.NAME,
            "description": self.description,
            #"lvl": self.lvl,
            "cost": self.cost,
            "rawcost": self.rawcost,
            #"is_hidden": defaultdict(str,self._weapon_data)["hidden"]=="1",
            "icon": self.icon,
            "faction": self.faction,
            "attributes": self.attributes,
            "subweapons": self.subweapons
        }

class WeaponPap_Dummy:
    def __init__(self, init_pap_paths:int):
        self.papskip:str = "0"
        self.pappaths:int = init_pap_paths

class GenericItem:
    def __init__(self, item_data: dict[str,Any]):
        self.is_item_category:bool="enhanceweapon_click" not in item_data and "cost" not in item_data
        self.is_weapon:bool=(("desc" in item_data) or ("author" in item_data)) and "weaponkit" not in item_data
        self.is_weapon_kit:bool="weaponkit" in item_data
        self.is_trophy:bool="desc" in item_data and "visual_desc_only" in item_data
        self.is_category:bool="author" not in item_data and ("filter" in item_data or "nokit" in item_data) and "whiteout" not in item_data
        self.is_text:bool="whiteout" in item_data

util.log("Parsing Weapon List...")

def item_block(key:str, data:dict[str,Any], output:dict[str,Any], type_override:str) -> dict[str,Any]:
    if ("hidden" not in data) or key=="Koshi's Goods":
        if key=="Koshi's Goods":
            output["$description"] = [
                "Only available in the Freeplay gamemode."
            ]
        for item in data:
            item_data = data[item]
            itm = GenericItem(item_data)
            if item in ITEM_BLACKLIST:
                continue
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
                name = util.get_key(item, silent=True)
                output["$items"].append({
                    "type": "trophy",
                    "name": name,
                    "wid": util.id_from_str(name),
                    "tags": [],
                    "description": util.get_key(item_data["desc"], silent=True),
                    "wtags": "",
                    "wcfghidden": ""
                })
            elif itm.is_weapon:
                wep = Weapon(item,item_data)
                if len(override_keys := type_override.split(",")) > 0:
                    if len(override_keys[0])>0:
                        wep.type=override_keys[0] # type:ignore[w]
                    if "nohide" in override_keys:
                        wep.IS_HIDDEN=False
                wep.add_global_tags()
                output["$items"].append(wep)
            elif itm.is_weapon_kit:
                kit = Weapon(item,item_data)
                if len(override_keys := type_override.split(",")) > 0:
                    kit.type = override_keys[0] # type: ignore[w]
                kit.add_global_tags()
                kit.subweapons["name"] = "Kit Items"
                kit.subweapons["items"] = []

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
                elif key == "Koshi's Goods":
                    type_override = "upgrade,nohide"
                output[item] = item_block(item, item_data, defaultdict(list),type_override)
                type_override = prev_override
            elif "Trophies" == item:
                output[item] = item_block(item, item_data, defaultdict(list), "")
            elif itm.is_text: # Text shown in menu
                output["$description"].append(item)
    return output

WEAPONSDATA = {}
type_override = ""
for item_category in CFG_WEAPONS.keys(): # type: ignore[w]
    if GenericItem(CFG_WEAPONS[item_category]).is_item_category: # type: ignore[w]
        if item_category == "Upgrades":
            type_override = "upgrade"
        output = item_block(item_category, CFG_WEAPONS[item_category], defaultdict(list), type_override) # type: ignore[w]
        type_override = ""
        if output: # no empty categories
            WEAPONSDATA[item_category] = output

WEAPONSDATA["$gtags"] = g_tags

util.write("gh-pages/data/items.json", json.dumps(WEAPONSDATA,indent=2))
