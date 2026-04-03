import util, json
from keyvalues1 import KeyValues1
from requests.structures import CaseInsensitiveDict

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
util.log("Parsing all phrases...")
for p in PHRASES:
    util.log(f"> {p}")
    util.PHRASES.append(CaseInsensitiveDict(KeyValues1.parse(util.read(f"./TF2-Zombie-Riot/addons/sourcemod/translations/{p}"))["Phrases"]))