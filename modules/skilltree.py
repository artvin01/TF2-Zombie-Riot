# Parse Skilltree
import util
from keyvalues1 import KeyValues1

SKILLTREE_CFG = KeyValues1.parse(util.read("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/skilltree.cfg"))

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
    # strange formatting of the string I know
    MARKDOWN_SKILLTREE = """## Legend
- MIN: Minimum amount of ranks needed in parent skill to unlock  
- MAX: Maximum rank  
- COST: Amount of points needed per rank  
- REQ: Required item to unlock skill

```mermaid
    %%{init:{'theme':'forest'}}%%
    mindmap"""
    def skill_block(x,y,skill,parent_skill_key,skill_md,depth):
        depth += 1
        for subskill in skill.keys():
            if subskill.startswith("a"): # detect if key is an actual skill
                data = skill[subskill]

                if "min" in data: min_pts = f"\nMIN {data["min"]}"
                else: min_pts = ""

                if "key" in data: required_item = f"\nREQ {data["key"]}"
                else: required_item = ""

                if "cost" in data: cost = f"\nCOST {data["cost"]}"
                else: cost = ""

                desc = f"{data["name"]}{cost}\nMAX {data["max"]}{min_pts}{required_item}"
                skill_md += f'{" "*depth}{subskill}["{desc}"]\n'
                skill_md = skill_block(x,y,data,subskill,skill_md,depth)
        return skill_md
    
    MARKDOWN_SKILLTREE = skill_block(0,0,SKILLTREE_CFG,list(SKILLTREE_CFG.keys())[0],MARKDOWN_SKILLTREE,0)
    MARKDOWN_SKILLTREE += "```"
    util.write("skilltree.md", MARKDOWN_SKILLTREE)
    return {"skilltree.md": "Skilltree.md"}