import util, vtf2img, os
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
        npc_icon_path = f"./TF2-Zombie-Riot/materials/hud/{npc_icon_key}"
        premedia_npc_icon_path = f"./premedia_icons/{icon}.png"
        if os.path.isfile(npc_icon_path):
            if not os.path.isfile(npc_png_icon_path):
                npc_icon = vtf2img.Parser(f"./TF2-Zombie-Riot/materials/hud/{npc_icon_key}").get_image()
                npc_icon.save(npc_png_icon_path)
            return util.md_img(npc_png_icon_path,"A")
        elif os.path.isfile(premedia_npc_icon_path):
            return util.md_img(premedia_npc_icon_path,"B")
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

            
            desc_key = f"{self.name} Desc"
            self.description = util.get_key(desc_key, empty_on_fail=True, silent=True).replace("\\n", "<div class=\"flex_break\"></div>\n") # (Lots of NPCs with intentionally missing descriptions)
            
            """
            npc_obj = {
                "name": name,
                "category": category,
                "description": description, 
                "plugin": plugin, 
                "icon": icon, 
                "health": health, 
                "flags": flags,
                "filetype": filetype
            }
            """

        self.hidden = not ("npc_donoteveruse" not in self.file_data and "NPC_Add" in self.file_data)

    def _get_name(self):
        try:
            self.name = self.file_data.split(f"strcopy({self.main_prefix}.Name, sizeof({self.main_prefix}.Name), \"")[1].split("\");")[0]
        except IndexError:
            self.name = None
    

    def _parse_health_number(self, num):
        try:
            float(num)
            return num
        except ValueError:
            # Assume variable
            npc_vars = self.file_data.split("#define ")
            npc_vars_dict = {}
            for i, item in enumerate(npc_vars):
                if i > 0:
                    # May parse whole blocks of code as key&value pairs sometimes, but it gets the job done. Doesn't break actual variables in any way
                    full_str = item.split('"')
                    k, v = util.normalize_whitespace(full_str[0]).replace(" ",""), full_str[1].replace(" ","")
                    npc_vars_dict[k] = v

            if num in npc_vars_dict:
                util.debug(f"[X] {self.path} var {num}", "npc")
                return util.format_num(npc_vars_dict[num])
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
            self.category = f"404 prefix: {self.main_prefix}" if "npcs" in util.CATEGORIES else "-1"
        
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
            "health": self.health, 
            "flags": self.flags,
            "filetype": self.filetype
        }

class NPC_Dummy:
    def __init__(self, npc_obj: NPC):
        # yes this is stupid. I won't change it.
        self.name = npc_obj.name
        self.icon = npc_obj.icon
        self.description = npc_obj.description
        self.filetype = npc_obj.filetype
    
    def __json__(self):
        return {
            "name": self.name,
            "category": self.category,
            "description": self.description, 
            "plugin": self.plugin, 
            "icon": self.icon, 
            "health": self.health, 
            "flags": self.flags,
            "filetype": self.filetype
        }