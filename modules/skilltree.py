# Parse Skilltree
import util
import json
import vdf
from collections import defaultdict
from ruamel.yaml import YAML
from typing import Any

yaml=YAML(typ='safe')
SKILLTREE_CFG: dict[str,Any] = vdf.loads(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/skilltree.cfg")) # type: ignore[w]
with open("./config/skilltree.yml",'r') as file:
    PARSECFG = yaml.load(file) # type: ignore[w]

"""
   	"name"		"Luck Up 1"	            // Name
    "player"	"SkillPlayer_LuckUp"	// Function
//	"weapon"	"Tree_LuckUp"	        // Function
    "max"	"5"	                        // Max Charges
    "cost"	"1"	                        // Point Cost
//	"min"	"-1"	                    // Charge Required from Parent
//	"key"	""	                        // Inventory Item Required
"""
def skill_block(x:int, y:int, skill: dict[str,Any], skill_json:list[dict[str,str]], depth:int) -> list[dict[str,str]]:
    depth += 1
    for subskill in skill.keys():
        if subskill.startswith("a"): # detect if key is an actual skill
            data = defaultdict(str,skill[subskill])

            min_pts = int(data["min"]) if "min" in data else 0

            required_item = util.get_key(data["key"],empty_on_fail=True,silent=True)

            cost = 1 if data["cost"] == "" else max(int(data["cost"]),1)

            desc = util.get_key(data["name"] + " Desc")

            nx,ny=x,y
            if subskill.startswith("abb"):
                if subskill[-1] == "a":
                    nx-=1*PARSECFG.get(subskill,1)
                if subskill[-1] == "b":
                    ny+=1*PARSECFG.get(subskill,1)
                if subskill[-1] == "c":
                    ny-=1*PARSECFG.get(subskill,1)
            elif subskill.startswith("aba"): # Health Up branch (right)
                if subskill[-1] == "a":
                    nx+=1*PARSECFG.get(subskill,1)
                if subskill[-1] == "b":
                    ny+=1*PARSECFG.get(subskill,1)
                if subskill[-1] == "c":
                    ny-=1*PARSECFG.get(subskill,1)
            else:
                if subskill[-1] == "a":
                    ny-=1*PARSECFG.get(subskill,1)
                if subskill[-1] == "b":
                    nx+=1*PARSECFG.get(subskill,1)
                if subskill[-1] == "c":
                    if subskill.startswith("abb") or subskill.startswith("aab"):
                        nx-=1*PARSECFG.get(subskill,1)
                    else:
                        ny+=1*PARSECFG.get(subskill,1)

            #skill_md += f'{" "*depth}{subskill}["{desc}"]\n'
            util.log(f"{subskill:<10} {data["name"]:<32} {(nx,ny)}")
            skill_json.append({
                "name": util.get_key(data["name"]),
                "desc": desc,
                "minparent": min_pts,
                "max": data["max"],
                "reqkey": required_item,
                "cost": cost,
                "path": subskill,
                "paths": skill_block(nx,ny,data,[],depth),
                "pos": (nx,ny),
            })
    return skill_json

skilltree_pointmap = skill_block(0,0,SKILLTREE_CFG,[],0)
util.write("gh-pages/data/skilltree.json", json.dumps(skilltree_pointmap,indent=2))
