import util, vtf2img, os
import json

FLAG_MAPPINGS = {
    "MVM_CLASS_FLAG_NONE": "", #// Show Nothing
    "MVM_CLASS_FLAG_NORMAL": "Normal", #// Normal
    "MVM_CLASS_FLAG_SUPPORT": "Support", #// Support
    "MVM_CLASS_FLAG_MISSION": "<mark>Support</mark>", #// Support - Flashing for Spies, Busters, Engis
    "MVM_CLASS_FLAG_MINIBOSS": "Miniboss", #// Normal - Red Background
    "MVM_CLASS_FLAG_ALWAYSCRIT": "Crits", #// Add Blue Borders
    "MVM_CLASS_FLAG_SUPPORT_LIMITED": "Limited Support" #// Only Visible When Active (waveset viewer is static so no way to simulate this)
}
def get_npc_icon(icon):
    if icon!="":
        npc_icon_key = "leaderboard_class_"+icon+".vtf"
        npc_png_icon_path = f"repo_img/{icon}.png"
        
        # Paths to look in for icons
        npc_icon_path = f"TF2-Zombie-Riot/materials/hud/{npc_icon_key}"
        premedia_npc_icon_path = f"premedia_icons/{icon}.png"
        if os.path.isfile(npc_icon_path):
            if not os.path.isfile("gh-pages/"+npc_png_icon_path): # if file already made
                npc_icon = vtf2img.Parser(f"TF2-Zombie-Riot/materials/hud/{npc_icon_key}").get_image()
                npc_icon.save("gh-pages/"+npc_png_icon_path)
            return util.md_img("./"+npc_png_icon_path,"A")
        elif os.path.isfile("gh-pages/"+premedia_npc_icon_path):
            return util.md_img("./"+premedia_npc_icon_path,"B")
        else:
            return util.md_img("./builtin_img/missing.png","C")
    else:
        return util.md_img("./builtin_img/missing.png","D")
class NPC:
    def __init__(self, path):
        self.path=path
        util.debug(f"Init NPC {self.path}", "npcs", "OKCYAN")
        self.file_data = util.read(self.path)
        self.file_data = util.remove_multiline_comments(self.file_data)
        if ("npc_donoteveruse" not in self.file_data and "NPC_Add" in self.file_data):

            # Get NPC name
            # TODO multi-npc files can have different prefixes
            prefixes = [
                "data",
                "lantean_data",
                "data_buffed" # addons/sourcemod/scripting/zombie_riot/npc/bonezone/wave60/npc_necromancer.sp
            ]
            self.name = None
            for prefix in prefixes:
                if self.name is None: 
                    self.main_prefix = prefix
                    self._get_name()
            assert self.name is not None
            # Get NPC constants
            self.get_npc_constants()
            
            # Get plugin, category, flags, health
            if "shared" in self.path:
                self._set_npc_data_shared()
            if self.file_data.count("NPC_Add") > 1:
                self._set_npc_data_multi()
            else:
                self._set_npc_data_single()

            # Get icon
            try:
                self.icon = self.file_data.split(f"strcopy({self.main_prefix}.Icon, sizeof({self.main_prefix}.Icon), \"")[1].split("\");")[0]
            except IndexError:
                self.icon = ""
            
            # Get music
            # get all music as cutouts, starting at MusicEnum music; and ending at Music_SetRaidMusic( {parameters can vary}
            music_cutouts = [item.split("Music_SetRaidMusic(")[0] for i,item in enumerate(self.file_data.split("MusicEnum music;")) if i > 0]
            self.music_entries = []
            if len(music_cutouts) > 0:
                util.debug(f"NPC:__init__:music_cutouts\n{json.dumps(music_cutouts,indent=2)}","npcs", "OKBLUE")
                for code in music_cutouts:
                    self.music_entries.append({
                        "filename": self._get_music_val(code,"Path"),
                        "name": self._get_music_val(code,"Name"),
                        "artist": self._get_music_val(code,"Artist")
                    })
            
            desc_key = f"{self.name} Desc"
            # Lots of NPCs with intentionally missing descriptions, hence silent=True
            self.description = util.get_key(desc_key, empty_on_fail=True, silent=True).replace("\\n", "<div class=\"flex_break\"></div>\n")
            
            # may be a problem if for example a file has multiple npcs with one that doesn't have the logic
            self.has_prefix_logic = """bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];""" in self.file_data

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
                    "filename", "name", "artist"
                }
            }
            """

        self.hidden = not ("npc_donoteveruse" not in self.file_data and "NPC_Add" in self.file_data)

    def _get_name(self):
        try:
            self.name = self.file_data.split(f"strcopy({self.main_prefix}.Name, sizeof({self.main_prefix}.Name), \"")[1].split("\");")[0]
        except IndexError:
            self.name = None
    
    def _get_music_val(self, code, property_name):
        # gets a property of music and fetches it from constants if needed
        # e.g. code.split("strcopy(music.Path, sizeof(music.Path), ")[1].split(");")[0]
        val = code.split(f"strcopy(music.{property_name}, sizeof(music.{property_name}), ")[1].split(");")[0]
        if val in self.npc_vars_dict: return self.npc_vars_dict[val]
        return val.replace("\"","")
    
    def get_npc_constants(self):
        npc_vars = self.file_data.split("#define ")
        self.npc_vars_dict = {}
        for i, item in enumerate(npc_vars):
            if i > 0: # all of the stuff before #define is pointless
                # May parse whole blocks of code as key&value pairs sometimes, but it gets the job done. Doesn't break actual variables in any way
                full_str = util.normalize_whitespace(item.replace("\t"," ")).split(' ')
                util.debug(f"NPC:get_npc_constants:full_str[1] {full_str[1]}", "npcs", "OKCYAN")
                # e.g. '4500static' fixed temporarily by just removing "static". gotta fix this later, it seems like it doesn't get split by newlines or smth
                k, v = full_str[0].replace(" ",""), full_str[1].split("\n")[0].split("//")[0].replace(" ","").replace("\"","").replace("static","")
                util.debug(f"NPC:get_npc_constants:k, v {k}, {v}", "npcs", "OKCYAN")
                self.npc_vars_dict[k] = v
    
    def _parse_health_number(self, num):
        try:
            float(num)
            return num
        except ValueError:
            # Assume var/constant in code
            if num in self.npc_vars_dict:
                util.debug(f"[X] {self.path} var {num}", "npc")
                return util.format_num(self.npc_vars_dict[num])
            else:
                util.debug(f"[ ] {self.path} var {num}", "npc")
                return "?"
                #return "dynamic"
    
    def _set_npc_data_shared(self):
        # Several instances of NPC entry data, several instances of CClotBody in separate files
        self.plugin = self.file_data.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")
        self.plugin = [item.split("\");")[0] for i,item in enumerate(self.plugin) if i > 0]

        self.category = self.file_data.split(f"{self.main_prefix}.Category = ")
        self.category = [item.split(";")[0] for i,item in enumerate(self.category) if i > 0]

        self.flags = self.file_data.split(f"{self.main_prefix}.Flags = ")
        self.flags = [item.split(";")[0].split("|") for i,item in enumerate(self.flags) if i > 0]

        base_path = self.path.replace(self.path.split("/")[-1],"") # remove deepest item
        self.health = []
        for i,p in enumerate(self.plugin):
            p_data = util.read(base_path+p+".sp")
            try:
                h = self.file_data.split("CClotBody(vecPos, vecAng, ")[1].split("));")[0].split(',')[2].replace('"',"").replace(" ","")
                #if "MinibossHealthScaling" in h:
                #    h = f"Miniboss health scaling (Base {h.split("(")[1][:-1]}HP)"
                if ":" in h:
                    """
                    extra "data" fields for enemies (lists, numbers or types like "Elite")
                    'data[0]?x' is probably checking if any value from the waveset cfg exists at all to use x? 
                    """
                    cases = h.split(":(")
                    if len(cases) == 0: cases = h.split(":")
                    h = {}
                    def parse_case(c):
                        if "?" in c:
                            k,v = c.split("?")
                            if k.startswith("data"): k="any"
                        else:
                            k,v = "default", c
                        v=v.replace(")","")
                        return k,v
                    for case in cases:
                        if ":" in case:
                            subcases = case.split(":")
                            for subcase in subcases:
                                k,v = parse_case(subcase)
                                h[k] = self._parse_health_number(v)
                        else:
                            k,v = parse_case(case)
                            h[k] = self._parse_health_number(v)
                else:
                    h = self._parse_health_number(health) + "HP"
            except IndexError:
                h = "?"
            self.health.append(h)

    def _set_npc_data_multi(self):
        # Several instances of NPC entry data, one instance of CClotBody
        self.plugin = self.file_data.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")
        self.plugin = [item.split("\");")[0] for i,item in enumerate(self.plugin) if i > 0]

        self.category = self.file_data.split(f"{self.main_prefix}.Category = ")
        self.category = [item.split(";")[0] for i,item in enumerate(self.category) if i > 0]

        self.flags = self.file_data.split(f"{self.main_prefix}.Flags = ")
        self.flags = [item.split(";")[0].split("|") for i,item in enumerate(self.flags) if i > 0]

        try:
            self.health = self.file_data.split("CClotBody(vecPos, vecAng, ")[1].split("));")[0].split(',')[2].replace('"',"").replace(" ","")
            #if "MinibossHealthScaling" in self.health:
            #    self.health = f"Miniboss health scaling (Base {self.health.split("(")[1][:-1]}HP)"
            if ":" in self.health:
                """
                extra "data" fields for enemies (lists, numbers or types like "Elite")
                'data[0]?x' is probably checking if any value from the waveset cfg exists at all to use x? 
                """
                cases = self.health.split(":(")
                if len(cases) == 0: cases = self.health.split(":")
                self.health = {}
                def parse_case(c):
                    if "?" in c:
                        k,v = c.split("?")
                        if k.startswith("data"): k="any"
                    else:
                        k,v = "default", c
                    v=v.replace(")","")
                    return k,v
                
                for case in cases:
                    if ":" in case:
                        subcases = case.split(":")
                        for subcase in subcases:
                            k,v = parse_case(subcase)
                            self.health[k] = self._parse_health_number(v)
                    else:
                        k,v = parse_case(case)
                        self.health[k] = self._parse_health_number(v)
            else:
                self.health = self._parse_health_number(self.health) + "HP"
        except IndexError:
            self.health = "?"
    
        self.filetype = "multi"
    
    def _set_npc_data_single(self):
        # One instance of everything
        self.plugin = self.file_data.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")[1].split("\");")[0]

        try:
            self.category = self.file_data.split(f"{self.main_prefix}.Category = ")[1].split(";")[0]
        except IndexError:
            self.category = f"404 prefix: {self.main_prefix}" if "npcs" in util.DEBUG else "-1"
        
        try:
            self.flags = self.file_data.split(f"{self.main_prefix}.Flags = ")[1]
            self.flags = self.flags.split(";")[0].split("|")
        except IndexError:
            self.flags = []
        
        try:
            self.health = self.file_data.split("CClotBody(vecPos, vecAng, ")[1].split("));")[0].split(',')[2].replace('"',"").replace(" ","")
            #if "MinibossHealthScaling" in self.health:
            #    self.health = f"Miniboss health scaling (Base {self.health.split("(")[1][:-1]}HP)"
            if ":" in self.health:
                """
                extra "data" fields for enemies (lists, numbers or types like "Elite")
                'data[0]?x' is probably checking if any value from the waveset cfg exists at all to use x? 
                """
                cases = self.health.split(":(")
                if len(cases) == 0: cases = self.health.split(":")
                self.health = {}
                def parse_case(c):
                    if "?" in c:
                        k,v = c.split("?")
                        if k.startswith("data"): k="any"
                    else:
                        k,v = "default", c
                    v=v.replace(")","")
                    return k,v
                for case in cases:
                    if ":" in case:
                        subcases = case.split(":")
                        for subcase in subcases:
                            k,v = parse_case(subcase)
                            self.health[k] = self._parse_health_number(v)
                    else:
                        k,v = parse_case(case)
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
            "has_prefix_logic": self.has_prefix_logic
        }

class NPC_Dummy:
    def __init__(self, npc_obj: NPC):
        # yes this is stupid. I won't change it.
        self.name = npc_obj.name
        self.icon = npc_obj.icon
        self.description = npc_obj.description
        self.filetype = npc_obj.filetype
        self.has_prefix_logic = npc_obj.has_prefix_logic
        self.music_entries = []
    
    def __json__(self):
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