import util
import json
from unicodedata import name as unicode_name
# addons/sourcemod/scripting/shared/status_effects.sp
# Start: strcopy(data.BuffName, sizeof(data.BuffName),
# End: StatusEffect_AddGlobal(data);
# - No other prefixes
# - Some attributes defined inbetween but that might be too much to account for
"""
strcopy(data.BuffName, sizeof(data.BuffName), "Specter's Aura");
strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₪");
strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
//-1.0 means unused
data.DamageTakenMulti 			= -1.0;
data.DamageDealMulti			= -1.0;
data.MovementspeedModif			= 0.6;
data.Positive 					= false;
data.ShouldScaleWithPlayerCount = false;
data.Slot						= 0; //0 means ignored
data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
StatusEffect_AddGlobal(data);
"""

EFFECTDATA = []

FILEDATA = util.read("./TF2-Zombie-Riot/addons/sourcemod/scripting/shared/status_effects.sp")

effectdata = FILEDATA.split("strcopy(data.BuffName, sizeof(data.BuffName),")
effectdata = [item.split("StatusEffect_AddGlobal(data);")[0] for i,item in enumerate(effectdata) if i > 0]
effectdata_parsed: list[dict[str,str]] = []
for status_effect in effectdata:
    data = {
        "name": util.get_key(name:=status_effect[2:].split('");')[0], silent=True, empty_on_fail=True),
        "description": util.get_key(f"{name} Desc", silent=bool(name)), # don't show warning if there also is no translation for name
        "icon": (icon:="") if (icon := status_effect.split('sizeof(data.HudDisplay), \"')[1].split('");')[0])==" " else icon,
        "icon_name": " ".join([unicode_name(ch) for ch in icon]),
        "type": json.loads(status_effect.split("data.Positive")[1].split(";")[0].strip()[2:]), # always returns e.g. '= false' so strip first 2 chars -> true: Buff, false: Debuff
        "id": util.id_from_str(f"{name}{icon}")
        #"aboveenemydisplay": (se if len(se:=status_effect.split('sizeof(data.AboveEnemyDisplay), \"'))>1 else ["",""])[1].split('");')[0] # only used for BEER
    }
    if data["name"] and data["icon"]:
        effectdata_parsed.append(data)

util.write("gh-pages/data/status_effects.json", json.dumps(effectdata_parsed,indent=2))
