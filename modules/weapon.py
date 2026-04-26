# Parse all items, weapons and their paps.
import util
import vdf

CFG_WEAPONS = vdf.loads(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/weapons.cfg"))["Weapons"]

class WeaponPap:
    def __init__(self, weapon_name, weapon_data, idx, depth):
        self.depth = depth
        pap_key = f"pap_{idx}_"
        key_desc = pap_key+"desc"
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

            self.attributes = weapon_data[pap_key+"attributes"]
            self.id = util.id_from_str(self.attributes)
        
        self.valid = key_desc in weapon_data


    def to_md(self):
        desc = util.get_key(self.description)
        
        extra_desc = self.extra_desc if len(self.extra_desc) > 0 else ""

        space_header = " "*self.depth
        space = " "*round(self.depth*1.5) # Scale a bit to align with header spacing

        if len(self.tags)>0: tags = f"{space}{self.tags}  \n"
        else: tags = ""

        return f"### {space_header} {self.name} \\[{self.id}\\]  \n{tags}{space}${self.cost}  \n{space}{desc.replace("\\n",f"  \n{space}")}  \n{space}{extra_desc.replace("\\n",f"  \n{space}")}  \n"
    
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
            "desc": f"{util.divfornewline(desc)}{util.divfornewline(extra_desc)}",
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


def parse():
    util.log("Parsing Weapon List...")

    HTML_WEAPON = ""
    
    def is_item_category(c):
        return "enhanceweapon_click" not in c and "cost" not in c


    def is_weapon(c):
        return (("desc" in c) or ("author" in c)) and not "weaponkit" in c


    def is_trophy(c):
        return "desc" in c and "visual_desc_only" in c


    def is_category(c):
        return "author" not in c and "filter" in c and "whiteout" not in c

    def interpret_weapon_paps(weapon_name,weapon_data):
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
                pd = WeaponPap(weapon_name,weapon_data,idx,depth)
                if pd.valid:
                    html += pd.to_html()
                    if pd.pappaths!="0": html = item_block(pd, idx+int(pd.papskip), html, depth+1)
            html += "</div>\n"
            return html
        
        if "pappaths" in weapon_data: init_pap_paths = weapon_data["pappaths"]
        else: init_pap_paths = 1
        pap_html = item_block(WeaponPap_Dummy(init_pap_paths), pap_idx, pap_html, 0)
        if len(pap_html)>0:
            pap_html += "\n"
        return pap_html


    def parse_weapon_data(weapon_name, weapon_data, depth, gtags):
        if "tags" in weapon_data:
            taglist = weapon_data["tags"].split(";")
            if "," in weapon_data["tags"]: taglist = weapon_data["tags"].split(",") # crystal shard uses commas instead of semicolons. blame artvin
            tags = " ".join(f"#{tag}" for tag in taglist if tag != "" and len(tag)>2)
            for tag in taglist:
                if tag.capitalize() not in gtags and tag not in gtags and len(tag)>2: gtags.append(tag)
        else: tags = ""

        if "author" in weapon_data: author = f"By {weapon_data["author"]}"
        else: author = ""

        cost = weapon_data["cost"]
        if cost=="0": cost="Free"

        if "desc" in weapon_data: 
            k = weapon_data["desc"]
            description = util.get_key(k)
            description = description.replace("\\n","\n").replace("\n-","\n - ")
            if description.startswith("-"): description=" - "+description[1:]
        else: description = ""

        if "level" in weapon_data:
            lvl = f"Level: {weapon_data["level"]}  \n"
        else:
            lvl = ""

        paps_html = interpret_weapon_paps(weapon_name,weapon_data)
        
        hidden_str = "<i>Hidden</i>\n" if "hidden" in weapon_data else ""
        context = {
            "tags": tags,
            "author": util.apply_morecolors(author),
            "cost": cost,
            "desc": f"{hidden_str}<div>{lvl}</div>{util.divfornewline(description)}",
        }


        return util.fill_template(util.read("templates/items/item.html"), context), tags, paps_html, gtags
        
        #return f"##{"#"*depth} {weapon_name}  \n{tags}  \n{author}  \n{cost}  \n{lvl}{description}  \n{pap_links}  ", header, pap_md, gtags


    def item_block(key,data,depth,html, tags):
        if "hidden" not in data:
            depth += 1
            html += util.fill_template(util.read("templates/items/item_block_start.html"),{"key":key})
            for item in data:
                item_data = data[item]
                if is_trophy(item_data):
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
                    html += util.fill_template(util.read("templates/items/item_preview.html"), context)
                elif is_weapon(item_data):
                    item_html, wtags, item_paps, tags = parse_weapon_data(item,item_data,depth,tags)
                    # item
                    is_hidden = "hidden" in item_data
                    context = {
                        "name": item,
                        "data_item": item_html,
                        "wtags": wtags,
                        "wcfghidden": "weapon_cfghidden hidden" if is_hidden else ""
                    }
                    html += util.fill_template(util.read("templates/items/item_preview.html"), context)

                    # paps
                    context = {
                        "wtags": wtags,
                        "wcfghidden": "weapon_cfghidden" if is_hidden else "" # paps are hidden by default
                    }
                    html += util.fill_template(item_paps, context)
                elif "weaponkit" in item_data:
                    item_html, wtags, item_paps, tags = parse_weapon_data(item,item_data,depth,tags)
                    # kit (has no paps)
                    context = {
                        "name": item,
                        "data_item": item_html,
                        "wtags": wtags,
                        "wcfghidden": ""
                    }
                    html += util.fill_template(util.read("templates/items/item_preview.html"), context)
                    html += f"<div style=\"margin-left: 10px;\">\n"
                    
                    # kit items (has pap)
                    for k,v in item_data.items():
                        if is_weapon(v):
                            item_html, _, item_paps, tags = parse_weapon_data(k,v,depth,tags) # kit items never have tags on their own
                            # item
                            context = {
                                "name": k,
                                "data_item": item_html,
                                "wtags": wtags,
                                "wcfghidden": ""
                            }
                            html += util.fill_template(util.read("templates/items/item_preview.html"), context)
                            # paps
                            html += util.fill_template(item_paps, {"wtags":wtags})                            
                    html += "</div>\n"

                elif item[0].isupper() and is_category(item_data) or "Perks" in item: # unneeded data is always lowercase...
                    html, tags = item_block(item, item_data, depth, html, tags)
                elif "Trophies" == item: # Item
                    html, tags = item_block(item, item_data, depth, html, tags)
                elif "whiteout" in item_data: # Text shown in menu
                    html += item + "\n"
            html += "</details>\n"
        return html, tags


    tags = []
    for item_category in CFG_WEAPONS:
        if is_item_category(CFG_WEAPONS[item_category]):
            HTML_WEAPON, tags = item_block(item_category,CFG_WEAPONS[item_category],0, HTML_WEAPON, tags)
    
    tags_html = "".join([f"<div class=\"btn\" tabindex=\"0\" onclick=\"filter_set_tag('{tag}');\">#{tag}</div>" for tag in tags])
    context = {
        "gtags": tags_html,
        "itemdata": HTML_WEAPON
    }
    util.write("gh-pages/items.html", util.fill_template(util.read("templates/items/items.html"), context))