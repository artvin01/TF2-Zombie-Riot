import util
import vdf
from requests.structures import CaseInsensitiveDict

if "decompile" not in util.DEBUG:
    PHRASES = util.load_yaml("./config/phrases.yml") # type: ignore[w]
    util.log("Parsing phrases...")
    for p in PHRASES:
        util.log(f"> {p}")
        util.RAW_PHRASE[p] = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/translations/{p}")
        util.PHRASES.append(CaseInsensitiveDict(vdf.loads(util.RAW_PHRASE[p])["Phrases"])) # type: ignore[w]
        util.RAW_PHRASE[p] = util.RAW_PHRASE[p].splitlines()
else:
    util.log("DEBUG=decompile; Skipping phrase parsing!")
