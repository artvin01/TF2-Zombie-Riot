import util, json, modules.shared

"""
    {
      "name": "Refragmented W.F. Rifler",
      "category": "Type_Aperture",
      "description": "Spawns 2 Refragmented Metro Raiders, kill him to kill them.",
      "plugin": "npc_refragmented_combine_soldier_ar2",
      "icon": "combine_rifle",
      "flags": [
        "0"
      ],
      "filetype": "single"
    },
"""

def map_flags(flags):
    mapped = ""
    for i,flag in enumerate(flags):
        if flag != "0" and flag != "-1":
            mapped += f"{modules.shared.FLAG_MAPPINGS[flag]}{", " * int(i != len(flags)-1)}"
    return mapped

def parse():
    util.log("Parsing NPCs into an encyclopedia...")
    NPCS_BY_CATEGORY = json.loads(util.read("npcs_by_category.json"))
    npc_list_html = ""
    for category, npc_list in NPCS_BY_CATEGORY.items():
        category_name = category.replace("Type_","").replace("-1","Unknown").title()
        if category != "Type_Hidden":
            npc_list_html += util.fill_template(util.read("templates/npc/category_block_start.html"),{"key":category_name})
            for npc in npc_list:
                context = {
                    "npc_name": f"{modules.shared.get_npc_icon(npc["icon"])} {npc["name"]}",
                    "plugin_name": npc["plugin"],
                    "flags": map_flags(npc["flags"]),
                    "desc": f"<div>{npc["description"].replace("\n","</div>\n<div>")}</div>\n"
                }
                npc_list_html += util.fill_template(util.read("templates/npc/npc_preview.html"),context)
            npc_list_html += "</details>\n"

    context = {
        "npcdata": npc_list_html
    }
    util.write("gh-pages/npcs.html", util.fill_template(util.read("templates/npc/npcs.html"),context))