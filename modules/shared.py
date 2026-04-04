import util, vtf2img, os
# TODO in waveset display, show npcs flagged as support separately, just like in tf2
FLAG_MAPPINGS = {
    "MVM_CLASS_FLAG_NONE": "",
    "MVM_CLASS_FLAG_NORMAL": "Normal",
    "MVM_CLASS_FLAG_SUPPORT": "Support",
    "MVM_CLASS_FLAG_MISSION": "<mark>Support</mark>",
    "MVM_CLASS_FLAG_MINIBOSS": "Miniboss",
    "MVM_CLASS_FLAG_ALWAYSCRIT": "Crits",
    "MVM_CLASS_FLAG_SUPPORT_LIMITED": "Limited Support"
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
        util.debug(f"Init NPC {self.path}", "npc", "OKCYAN")
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
            
            # Get plugin, category, flags
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
                "flags": flags,
                "filetype": filetype,
                "has_prefix_logic": has_prefix_logic
            }
            """

        self.hidden = not ("npc_donoteveruse" not in self.file_data and "NPC_Add" in self.file_data)

    def _get_name(self):
        try:
            self.name = self.file_data.split(f"strcopy({self.main_prefix}.Name, sizeof({self.main_prefix}.Name), \"")[1].split("\");")[0]
        except IndexError:
            self.name = None
    
    def _set_npc_data_shared(self):
        # Several instances of NPC entry data, several instances of CClotBody in separate files
        self.plugin = self.file_data.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")
        self.plugin = [item.split("\");")[0] for i,item in enumerate(self.plugin) if i > 0]

        self.category = self.file_data.split(f"{self.main_prefix}.Category = ")
        self.category = [item.split(";")[0] for i,item in enumerate(self.category) if i > 0]

        self.flags = self.file_data.split(f"{self.main_prefix}.Flags = ")
        self.flags = [item.split(";")[0].split("|") for i,item in enumerate(self.flags) if i > 0]

    def _set_npc_data_multi(self):
        # Several instances of NPC entry data, one instance of CClotBody
        self.plugin = self.file_data.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")
        self.plugin = [item.split("\");")[0] for i,item in enumerate(self.plugin) if i > 0]

        self.category = self.file_data.split(f"{self.main_prefix}.Category = ")
        self.category = [item.split(";")[0] for i,item in enumerate(self.category) if i > 0]

        self.flags = self.file_data.split(f"{self.main_prefix}.Flags = ")
        self.flags = [item.split(";")[0].split("|") for i,item in enumerate(self.flags) if i > 0]
    
        self.filetype = "multi"
    
    def _set_npc_data_single(self):
        # One instance of everything
        self.plugin = self.file_data.split(f"strcopy({self.main_prefix}.Plugin, sizeof({self.main_prefix}.Plugin), \"")[1].split("\");")[0]

        try:
            self.category = self.file_data.split(f"{self.main_prefix}.Category = ")[1].split(";")[0]
        except IndexError:
            self.category = f"404 prefix: {self.main_prefix}" if "npcs" in util.CATEGORIES else "-1"
        
        try:
            self.flags = self.file_data.split(f"{self.main_prefix}.Flags = ")[1]
            self.flags = self.flags.split(";")[0].split("|")
        except IndexError:
            self.flags = []
        
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