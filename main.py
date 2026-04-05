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
    print("wavesets.py ----------------------------------------------------------------------------------")
    import modules.wavesets
    modules.wavesets.parse()

if "npcs" in SCOPE: # NOTE: NPC data parsed into json in modules/wavesets.py
    print("npcs.py ----------------------------------------------------------------------------------")
    import modules.npcs
    modules.npcs.parse()

if "items" in SCOPE:
    print("weapon.py ----------------------------------------------------------------------------------")
    import modules.weapon
    modules.weapon.parse()

if "skilltree" in SCOPE:
    print("skilltree.py ----------------------------------------------------------------------------------")
    import modules.skilltree
    modules.skilltree.parse()

import util
if util.LOG_REDACT:
    util.log("! Writing logs")
    util.write("logs.txt",util.LOGS)