# Parse Skilltree
import util, json, vdf, subprocess, os
from collections import defaultdict
from ruamel.yaml import YAML

yaml=YAML(typ='safe')
SKILLTREE_CFG = vdf.loads(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/skilltree.cfg"))
with open("./config/skilltree.yml",'r') as file:
    PARSECFG = yaml.load(file)

def parse():
    util.log("Parsing Skilltree...")
    """
    	"name"		"Luck Up 1"	            // Name
        "player"	"SkillPlayer_LuckUp"	// Function
    //	"weapon"	"Tree_LuckUp"	        // Function
        "max"	"5"	                        // Max Charges	
        "cost"	"1"	                        // Point Cost
    //	"min"	"-1"	                    // Charge Required from Parent
    //	"key"	""	                        // Inventory Item Required
    """
    skilltree_pointmap = []
    def skill_block(x,y,skill,parent_skill_key,skill_json,depth):
        depth += 1
        for subskill in skill.keys():
            if subskill.startswith("a"): # detect if key is an actual skill
                data = defaultdict(str,skill[subskill])

                min_pts = int(data["min"]) if "min" in data else 0

                required_item = util.get_key(data["key"],empty_on_fail=True,silent=True)

                cost = data["cost"]

                desc = util.get_key(data["name"] + " Desc")

                nx,ny=x,y
                if subskill.startswith("abc") and len(subskill) > 3: # Completely flip buildings and revive branch
                    if subskill[-1] == "a": ny+=1*PARSECFG.get(subskill,1)
                    if subskill[-1] == "b": nx+=1*PARSECFG.get(subskill,1)
                    if subskill[-1] == "c": ny-=1*PARSECFG.get(subskill,1)
                elif subskill.startswith("abbaac") and len(subskill)>6:
                    if subskill[-1] == "a": nx-=1*PARSECFG.get(subskill,1)
                    if subskill[-1] == "b": ny+=1*PARSECFG.get(subskill,1)
                    #if subskill[-1] == "c": ny-=1*PARSECFG.get(subskill,1)
                else:
                    if subskill[-1] == "a": ny-=1*PARSECFG.get(subskill,1)
                    if subskill[-1] == "b": nx+=1*PARSECFG.get(subskill,1)
                    if subskill[-1] == "c":
                        if subskill.startswith("abb") or subskill.startswith("aba") or subskill.startswith("aab"):
                            nx-=1*PARSECFG.get(subskill,1)
                        else:
                            ny+=1*PARSECFG.get(subskill,1)

                #skill_md += f'{" "*depth}{subskill}["{desc}"]\n'
                skill_json.append({
                    "name": util.get_key(data["name"]),
                    "desc": desc,
                    "minparent": min_pts,
                    "max": data["max"],
                    "reqkey": required_item,
                    "cost": cost,
                    "path": subskill,
                    "paths": skill_block(nx,ny,data,subskill,[],depth),
                    "pos": (nx,ny),
                })
        return skill_json
    
    skilltree_pointmap = skill_block(0,0,SKILLTREE_CFG,list(SKILLTREE_CFG.keys())[0],skilltree_pointmap,0)
    if not os.path.isdir("gh-pages/skilltree"): subprocess.run(["mkdir", "gh-pages/skilltree"])
    util.write("gh-pages/skilltree/skilltree.json", json.dumps(skilltree_pointmap,indent=2))