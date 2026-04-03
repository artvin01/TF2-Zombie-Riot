import os
SCOPE = []
if "SCOPE" in os.environ:
    SCOPE = [x.lower() for x in os.environ["SCOPE"].split(",")]
else:
    #SCOPE = ["wavesets", "npcs", "items", "skilltree"]
    SCOPE = ["wavesets", "npcs", "items"]
print("SCOPE", SCOPE)

import modules.phrase

if "wavesets" in SCOPE:
    import modules.wavesets
    modules.wavesets.parse()

if "npcs" in SCOPE: # NOTE: NPC data parsed into json in modules/wavesets.py
    import modules.npcs
    modules.npcs.parse()

if "items" in SCOPE:
    import modules.weapon
    modules.weapon.parse()

if "skilltree" in SCOPE:
    import modules.skilltree
    modules.skilltree.parse()