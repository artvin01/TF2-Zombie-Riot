import util
import json
import modules.shared

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

def map_flags(flags: list[str]) -> str:
    mapped = ""
    for i,flag in enumerate(flags):
        if flag != "0" and flag != "-1":
            mapped += f"{modules.shared.FLAG_MAPPINGS[flag]}{", " * int(i != len(flags)-1)}"
    return mapped

util.log("Parsing NPCs into an encyclopedia...")
NPCS_BY_CATEGORY = json.loads(util.read("gh-pages/data/npcs_by_category.json"))
npc_list_html = ""
for category, npc_list in sorted(NPCS_BY_CATEGORY.items()):
    category_name = category.replace("Type_","").replace("-1","Unknown").title()
    if category != "Type_Hidden":
        npc_list_html += util.fill_template(util.read("templates/npc/category_block_start.html"),{"key":category_name})
        if category == "Type_Raid":
            npc_list_html += '<div style="margin-bottom:1em;">This assumes you are on the final encounter unless stated otherwise.</div>\n'
        for npc in sorted(npc_list, key=lambda npc: npc["name"]):
            context = {}
            music = ""
            for entry in npc["music_entries"]:
                music += util.musicmodal_to_html(entry)

            # SOURCES
            src_icon = ("?",-1)
            if "source" in npc:
                if "icon" in npc["source"]:
                    src_icon = npc["source"]["icon"]

            context["npc_icon"] = util.html_img(modules.shared.get_npc_icon(npc["icon"]), src_icon)
            context["npc_name"] = npc["name"]
            context["plugin_name"] = npc["plugin"]
            context["flags"] = map_flags(npc["flags"])
            context["desc"] = f"{npc["description"].replace("\n","<br>")}"
            context["music"] =  music

            if "source" in npc: # order matters
                context["SRC_NAME"] = util.html_src(npc["source"]["name"])
                if "flags" in npc["source"]:
                    context["SRC_FLAGS"] = util.html_src(npc["source"]["flags"])
                context["SRC_DESC"] = util.html_src(npc["source"]["description"])

            npc_list_html += util.fill_template(util.read("templates/npc/npc_preview.html"),context)

        npc_list_html += "</details>\n"

context = {
    "npcdata": npc_list_html
}
util.write("gh-pages/npcs.html", util.fill_template(util.read("templates/npc/npcs.html"),context))
