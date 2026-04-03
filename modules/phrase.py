import util, json
from keyvalues1 import KeyValues1
PHRASES = [
    # wavesets.py
    "zombieriot.phrases.zombienames.txt",
    "zombieriot.phrases.item.gift.desc.txt",
    "zombieriot.phrases.txt",
    "zombieriot.phrases.rogue.txt",
    "zombieriot.phrases.rogue.paradox.txt",
    "zombieriot.phrases.rogue.rift.txt",
    "zombieriot.phrases.status_effects.txt",
    # weapon.py
    "zombieriot.phrases.weapons.description.txt",
    "zombieriot.phrases.weapons.txt"
]
PHRASES_MEM = []
util.log("Parsing all phrases...")
for p in PHRASES:
    util.log(f"> {p}")
    PHRASES_MEM.append(KeyValues1.parse(util.read(f"./TF2-Zombie-Riot/addons/sourcemod/translations/{p}"))["Phrases"])
util.write("phrase_cache.json",json.dumps(PHRASES_MEM,indent=2))