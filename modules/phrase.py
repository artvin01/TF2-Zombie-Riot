import util
import vdf
from requests.structures import CaseInsensitiveDict
from ruamel.yaml import YAML

if "decompile" not in util.DEBUG:
    yaml=YAML(typ='safe')
    with open("./config/phrases.yml",'r') as file:
        PHRASES = yaml.load(file) # type: ignore[w]
    util.log("Parsing phrases...")
    for p in PHRASES:
        util.log(f"> {p}")
        util.PHRASES.append(CaseInsensitiveDict(vdf.loads(util.read(f"./TF2-Zombie-Riot/addons/sourcemod/translations/{p}"))["Phrases"])) # type: ignore[w]
else:
    util.log("DEBUG=decompile; Skipping phrase parsing!")
