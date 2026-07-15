import util
import json
import os
from ruamel.yaml import YAML

# TODO source mapping: NPC shared.
# Where we left off: NPC single and multi implemented fully, sources are available, nothing else sourcified yet, gotta do a proof of concept JS inspect script for the NPC page now.

FLAG_MAPPINGS = {
    "MVM_CLASS_FLAG_NONE": "", #// Show Nothing
    "MVM_CLASS_FLAG_NORMAL": "", #// Normal
    "MVM_CLASS_FLAG_SUPPORT": "", #// Support
    "MVM_CLASS_FLAG_MISSION": "", #// Support - Flashing for Spies, Busters, Engis
    "MVM_CLASS_FLAG_MINIBOSS": "Miniboss", #// Normal - Red Background
    "MVM_CLASS_FLAG_ALWAYSCRIT": "Crits", #// Add Blue Borders
    "MVM_CLASS_FLAG_SUPPORT_LIMITED": "Limited Support" #// Only Visible When Active (waveset viewer is static so no way to simulate this) (also this may be completely unused in zr code)
}
FLAG_CSS = {
    "MVM_CLASS_FLAG_NONE": "", #// Show Nothing
    "MVM_CLASS_FLAG_NORMAL": "", #// Normal
    "MVM_CLASS_FLAG_SUPPORT": "flag_support", #// Support
    "MVM_CLASS_FLAG_MISSION": "flag_mission", #// Support - Flashing for Spies, Busters, Engis
    "MVM_CLASS_FLAG_MINIBOSS": "flag_miniboss", #// Normal - Red Background
    "MVM_CLASS_FLAG_ALWAYSCRIT": "flag_crits", #// Add Blue Borders
    "MVM_CLASS_FLAG_SUPPORT_LIMITED": "flag_support_limited" #// Only Visible When Active (waveset viewer is static so no way to simulate this)
}
PREFIX_STR = """bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];"""
yaml=YAML(typ='safe')
with open("./config/npc_whitelist.yml",'r') as file:
    NPC_WHITELIST = yaml.load(file) # type: ignore[w]

MISSING_ICON_VTF = "TF2-Zombie-Riot/materials/hud/leaderboard_class_robo_extremethreat.vtf"
MISSING_ICON_PNG = "repo_img/robo_extremethreat.png"
def get_npc_icon(icon:str) -> str:
    if icon!="":
        vtf_path = f"TF2-Zombie-Riot/materials/hud/leaderboard_class_{icon}.vtf"
        png_path = f"repo_img/{icon}.png"
        legacy_path = f"premedia_icons/{icon}.png"

        if os.path.isfile(vtf_path):
            return util.vtftoimg(vtf_path, png_path)
        elif os.path.isfile(f"gh-pages/{legacy_path}"):
            return f"./{legacy_path}"
        else:
            return util.vtftoimg(MISSING_ICON_VTF,MISSING_ICON_PNG)
    else:
        return util.vtftoimg(MISSING_ICON_VTF,MISSING_ICON_PNG)

global_vars: dict[str,str] = {} # RAIDBOSS_TWIRL_THEME is used for stella but is defined in twirl code...............
type TypeNPCData = None | bool | str | list[dict[str,str | bool]] | list[str] | list[list[str]] | dict[str,str] # what a mess
type TypeNPC = NPC | NPC_Dummy
class NPC:
    def __init__(self, path: str):
        self.PATH: str=path
        self.RELATIVE_PATH: str = path.replace(os.getcwd(),"").replace("/TF2-Zombie-Riot/","")
        util.debug(f"Init NPC {self.PATH}", "npcs", "OKCYAN")
        self.FILE_DATA: str = util.normalize_whitespace(
            util.remove_multiline_comments(
                util.read(self.PATH)
            ).replace("\t"," ")
        )
        self.FILE_DATA_RAW: str = util.readlines(self.PATH)
        self.FILE_DATA_SPLIT: list[str] = self.FILE_DATA_RAW.splitlines()
        self.HIDDEN: bool = not ("npc_donoteveruse" not in self.FILE_DATA and "NPC_Add" in self.FILE_DATA)
        if not self.HIDDEN:
            self.source: dict[str, dict[str,tuple[int,int]] | tuple[str,int]] = {}
            """
            return {
                "name": self.name, ✓
                "category": self.category,2/3
                "description": self.description, ✓
                "plugin": self.plugin,2/3
                "icon": self.icon, ✓
                "flags": self.flags,2/3
                "filetype": self.filetype,X
                "has_prefix_logic": self.has_prefix_logic,X
                "music_entries": self.music_entries, ✓
                "source": self.source
            }
            """
            # Get NPC name
            # TODO multi-npc files can have different prefixes (part of NPC code rewrite todo)
            prefixes = [
                "data",
                "lantean_data",
                "data_buffed" # addons/sourcemod/scripting/zombie_riot/npc/bonezone/wave60/npc_necromancer.sp
            ]
            self.name: None | str = None
            for prefix in prefixes:
                if self.name is None:
                    self.main_prefix:str = prefix
                    self._get_name()
            assert self.name is not None
            # Get NPC constants
            self.npc_vars_dict: dict[str,str] = {}
            self.get_npc_constants()

            # Get plugin, category, flags, health
            self.filetype: str | None = None
            self.plugin: str | list[str] = []
            self.category: str | list[str] = []
            self.flags: str | list[str] | list[list[str]] = []
            self.health: str | list[str] | dict[str,str] = []
            if "shared" in self.PATH:
                self._set_npc_data_shared()
            if self.FILE_DATA.count("NPC_Add") > 1:
                self._set_npc_data_multi()
            else:
                self._set_npc_data_single()

            # Get icon
            try:
                ICON_STR = f'strcopy({self.main_prefix}.Icon, sizeof({self.main_prefix}.Icon), \"'
                self.icon:str = self.FILE_DATA.split(ICON_STR)[1].split("\");")[0]
                self.source["icon"] = (self.RELATIVE_PATH, util.get_refs(self.FILE_DATA_SPLIT,ICON_STR)[0])
            except IndexError:
                self.icon = ""

            # Get music
            # get all music as cutouts, starting at MusicEnum music; and ending at Music_SetRaidMusic( {parameters can vary}
            music_cutouts = [item.split("Music_SetRaidMusic(")[0] for i,item in enumerate(self.FILE_DATA.split("MusicEnum music;")) if i > 0]
            self.music_entries: list[dict[str,str | bool]] = []
            if len(music_cutouts) > 0:
                music_hashes: list[str] = []
                music_cutout_source_start = util.get_refs(self.FILE_DATA_SPLIT, "MusicEnum music;")
                music_cutout_source_end = [util.get_refs(item.splitlines(), "Music_SetRaidMusic(", negative_on_fail=True)[0] for i,item in enumerate(self.FILE_DATA_RAW.split("MusicEnum music;")) if i > 0]
                util.debug(f"NPC:__init__:music_cutouts\n{json.dumps(music_cutouts,indent=2)}","npcs", "OKBLUE")
                for i, code in enumerate(music_cutouts):
                    mfilename = self._get_music_val(code,"Path").replace("#","")
                    filepath = f"https://raw.githubusercontent.com/artvin01/TF2-Zombie-Riot/refs/heads/master/sound/{mfilename}"
                    file_exists = os.path.isfile(f"./TF2-Zombie-Riot/sound/{mfilename}")
                    music_entry = {
                        "musicpre": "",
                        "musictitle": self._get_music_val(code,"Name"),
                        "musicartist": self._get_music_val(code,"Artist"),
                        "filepath": filepath,
                        "filename": mfilename,
                        "file_exists": file_exists
                    }
                    music_hash = util.id_from_str(json.dumps(music_entry)) # same music data will output same hash
                    if music_hash not in music_hashes:
                        self.music_entries.append(music_entry)
                        # music_cutout_source_end lines are relative to the starting lines!
                        #self.source["music"][filepath] = (self.RELATIVE_PATH, (music_cutout_source_start[i], music_cutout_source_start[i]+music_cutout_source_end[i])) # type:ignore[basedpyright doesnt get it]
                        music_entry["source"] = (self.RELATIVE_PATH, (music_cutout_source_start[i], (music_cutout_source_start[i]+music_cutout_source_end[i])-1)) # type:ignore[basedpyright doesnt get it]
                        music_hashes.append(music_hash)

            desc_key = f"{self.name} Desc"
            # Lots of NPCs with intentionally missing descriptions, hence silent=True
            self.description: str = util.get_key(desc_key, empty_on_fail=True, silent=True).replace("\\n", "<div class=\"flex_break\"></div>\n")
            self.source["description"] = util.get_key_src(desc_key)

            # may be a problem if for example a file has multiple npcs with one that doesn't have the logic
            self.has_prefix_logic: bool = PREFIX_STR in self.FILE_DATA # TODO add source?

            """
            npc_obj = {
                "name": name,
                "category": category,
                "description": description,
                "plugin": plugin,
                "icon": icon,
                "health": health,
                "flags": flags,
                "filetype": filetype,
                "has_prefix_logic": has_prefix_logic,
                "music_entries": {
                    "name", "filepath", "file_exists"FILE_DATA
                }
                "source": [see util.py:get_refs() usage]
            }
            """


    def _get_name(self):
        try:
            NAME_STR = f'strcopy({self.main_prefix}.Name, sizeof({self.main_prefix}.Name), \"'
            self.name = self.FILE_DATA.split(NAME_STR)[1].split("\");")[0]
            self.source["name"] = (self.RELATIVE_PATH, util.get_refs(self.FILE_DATA_SPLIT, NAME_STR)[0]) # TODO reference translations too?
        except IndexError:
            self.name = None


    def _get_music_val(self, code: str, property_name: str) -> str:
        # gets a property of music and fetches it from constants if needed
        # e.g. code.split("strcopy(music.Path, sizeof(music.Path), ")[1].split(");")[0]
        # also returns the line on which it is found
        MUSIC_STR = f"strcopy(music.{property_name}, sizeof(music.{property_name}), "
        val = code.split(MUSIC_STR)[1].split(");")[0]
        if val in self.npc_vars_dict:
            return self.npc_vars_dict[val]
        if val in global_vars:
            return global_vars[val]
        return val.replace("\"","")


    def get_npc_constants(self):
        npc_vars = self.FILE_DATA.split("#define ")
        for i, item in enumerate(npc_vars):
            if i > 0: # all of the stuff before #define is pointless
                # May parse whole blocks of code as key&value pairs sometimes, but it gets the job done. Doesn't break actual variables in any way
                full_str = util.normalize_whitespace(item.replace("\t"," ")).split(' ')
                util.debug(f"NPC:get_npc_constants:full_str[1] {full_str[1]}", "npcs", "OKCYAN")
                # e.g. '4500static' fixed temporarily by just removing "static". gotta fix this later, it seems like it doesn't get split by newlines or smth
                k, v = full_str[0].replace(" ",""), full_str[1].splitlines()[0].split("//")[0].replace(" ","").replace("\"","").replace("static","")
                util.debug(f"NPC:get_npc_constants:k, v {k}, {v}", "npcs", "OKCYAN")
                self.npc_vars_dict[k] = v
                if v.endswith(".mp3"):
                    global global_vars
                    global_vars[k]=v


    def _parse_health_number(self, num:str) -> str:
        try:
            float(num)
            return num
        except ValueError:
            # Assume var/constant in code
            if num in self.npc_vars_dict:
                util.debug(f"[X] {self.PATH} var {num}", "npcs")
                return util.format_num(self.npc_vars_dict[num])
            else:
                util.debug(f"[ ] {self.PATH} var {num}", "npcs")
                return "?"


    def _parse_case(self, c: str) -> tuple[str,str]:
        if "?" in c:
            k,v = c.split("?")
            if k.startswith("data"):
                k="any"
        else:
            k,v = "default", c
        v=v.replace(")","")
        return k,v


    def _set_npc_data_shared(self): # TODO fix this mess of a function
        # Several instances of NPC entry data, several instances of CClotBody in separate files
        self.plugin = self.FILE_DATA.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")
        self.plugin = [item.split("\");")[0] for i,item in enumerate(self.plugin) if i > 0]

        self.category = self.FILE_DATA.split(f"{self.main_prefix}.Category = ")
        self.category = [item.split(";")[0] for i,item in enumerate(self.category) if i > 0]

        self.flags = self.FILE_DATA.split(f"{self.main_prefix}.Flags = ")
        self.flags = [item.split(";")[0].split("|") for i,item in enumerate(self.flags) if i > 0]

        #base_path = self.PATH.replace(self.PATH.split("/")[-1],"") # remove deepest item
        self.health = []
        for _,_ in enumerate(self.plugin): # both vars unused????
            #p_data = util.read(base_path+p+".sp") # what the hell is this
            try:
                h = self.FILE_DATA.split("CClotBody(vecPos, vecAng, ")[1].split("));")[0].split(',')[2].replace('"',"").replace(" ","")
                if ":" in h:
                    """
                    extra "data" fields for enemies (lists, numbers or types like "Elite")
                    'data[0]?x' is probably checking if any value from the waveset cfg exists at all to use x?
                    """
                    cases = h.split(":(")
                    if len(cases) == 0:
                        cases = h.split(":")
                    h = {}
                    for case in cases:
                        if ":" in case:
                            subcases = case.split(":")
                            for subcase in subcases:
                                k,v = self._parse_case(subcase)
                                h[k] = self._parse_health_number(v)
                        else:
                            k,v = self._parse_case(case)
                            h[k] = self._parse_health_number(v)
                else:
                    raise NotImplementedError
            except IndexError:
                h = "?"
            self.health.append(h)


    def _set_npc_data_multi(self):
        # Several instances of NPC entry data, one instance of CClotBody
        self.plugin = self.FILE_DATA.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")
        self.plugin = [item.split("\");")[0] for i,item in enumerate(self.plugin) if i > 0]

        self.category = self.FILE_DATA.split(f"{self.main_prefix}.Category = ")
        self.category = [item.split(";")[0] for i,item in enumerate(self.category) if i > 0]

        self.flags = self.FILE_DATA.split(f"{self.main_prefix}.Flags = ")
        self.flags = [item.split(";")[0].split("|") for i,item in enumerate(self.flags) if i > 0]

        try:
            self.health = self.FILE_DATA.split("CClotBody(vecPos, vecAng, ")[1].split("));")[0].split(',')[2].replace('"',"").replace(" ","")
            #if "MinibossHealthScaling" in self.health:
            #    self.health = f"Miniboss health scaling (Base {self.health.split("(")[1][:-1]}HP)"
            if ":" in self.health:
                """
                extra "data" fields for enemies (lists, numbers or types like "Elite")
                'data[0]?x' is probably checking if any value from the waveset cfg exists at all to use x?
                """
                cases = self.health.split(":(")
                if len(cases) == 0:
                    cases = self.health.split(":")
                self.health = {}
                for case in cases:
                    if ":" in case:
                        subcases = case.split(":")
                        for subcase in subcases:
                            k,v = self._parse_case(subcase)
                            self.health[k] = self._parse_health_number(v)
                    else:
                        k,v = self._parse_case(case)
                        self.health[k] = self._parse_health_number(v)
            else:
                self.health = self._parse_health_number(self.health) + "HP"
        except IndexError:
            self.health = "?"

        self.filetype = "multi"


    def _set_npc_data_single(self):
        # One instance of everything
        PLUGIN_STR = f'strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"'
        self.plugin = self.FILE_DATA.split(PLUGIN_STR)[1].split("\");")[0]
        self.source["plugin"] = (self.RELATIVE_PATH, util.get_refs(self.FILE_DATA_SPLIT,PLUGIN_STR)[0])

        try:
            CAT_STR = f"{self.main_prefix}.Category = "
            self.category = self.FILE_DATA.split(CAT_STR)[1].split(";")[0]
            self.source["plugin"] = (self.RELATIVE_PATH, util.get_refs(self.FILE_DATA_SPLIT,CAT_STR,negative_on_fail=True)[0])
        except IndexError:
            self.category = f"404 prefix: {self.main_prefix}" if "npcs" in util.DEBUG else "-1"

        try:
            FLAGS_STR = f"{self.main_prefix}.Flags = "
            self.flags = self.FILE_DATA.split(FLAGS_STR)[1]
            self.flags = self.flags.split(";")[0].split("|")
            self.source["flags"] = (self.RELATIVE_PATH, util.get_refs(self.FILE_DATA_SPLIT,FLAGS_STR,negative_on_fail=True)[0])
        except IndexError:
            self.flags = []

        try:
            HEALTH_STR = "CClotBody(vecPos, vecAng, "
            self.health = self.FILE_DATA.split(HEALTH_STR)[1].split("));")[0].split(',')[2].replace('"',"").replace(" ","")
            self.source["health"] = (self.RELATIVE_PATH, util.get_refs(self.FILE_DATA_SPLIT,HEALTH_STR,negative_on_fail=True)[0])
            #if "MinibossHealthScaling" in self.health:
            #    self.health = f"Miniboss health scaling (Base {self.health.split("(")[1][:-1]}HP)"
            if ":" in self.health:
                """
                extra "data" fields for enemies (lists, numbers or types like "Elite")
                'data[0]?x' is probably checking if any value from the waveset cfg exists at all to use x?
                """
                cases = self.health.split(":(")
                if len(cases) == 0:
                    cases = self.health.split(":")
                self.health = {}
                for case in cases:
                    if ":" in case:
                        subcases = case.split(":")
                        for subcase in subcases:
                            k,v = self._parse_case(subcase)
                            self.health[k] = self._parse_health_number(v)
                    else:
                        k,v = self._parse_case(case)
                        self.health[k] = self._parse_health_number(v)
            else:
                self.health = self._parse_health_number(self.health) + "HP"
        except IndexError:
            self.health = "?"

        self.filetype = "single"


    def __json__(self):
        return {
            "name": self.name,
            "category": self.category,
            "description": self.description,
            "plugin": self.plugin,
            "icon": self.icon,
            "flags": self.flags,
            "filetype": self.filetype,
            "has_prefix_logic": self.has_prefix_logic,
            "music_entries": self.music_entries,
            "source": self.source
        }

class NPC_Dummy():
    def __init__(self, npc_obj: NPC):
        # yes this is stupid. I won't change it.
        self.name: str | None = npc_obj.name
        self.icon: str = npc_obj.icon
        self.description: str = npc_obj.description
        self.filetype: str | None = npc_obj.filetype
        self.has_prefix_logic: bool = npc_obj.has_prefix_logic
        self.music_entries:list[dict[str,str | bool]] = npc_obj.music_entries

        self.plugin: str | list[str] = []
        self.category: str | list[str] = []
        self.flags: str | list[str] | list[list[str]] = []
        self.health: str | list[str] | dict[str,str] = []

    def __json__(self) -> dict[str, TypeNPCData]:
        return {
            "DUMMY":"",
            "name": self.name,
            "category": self.category,
            "description": self.description,
            "plugin": self.plugin,
            "icon": self.icon,
            "health": self.health,
            "flags": self.flags,
            "filetype": self.filetype,
            "has_prefix_logic": self.has_prefix_logic,
            "music_entries": self.music_entries
        }
