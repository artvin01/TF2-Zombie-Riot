# https://github.com/dixon2004/python-tf2-utilities/
import requests, vdf
from collections import defaultdict
def get_items_game() -> dict:
    response = requests.get('https://raw.githubusercontent.com/SteamDatabase/GameTracking-TF2/master/tf/scripts/items/items_game.txt', timeout=10)
    if response.status_code == 200:
        return vdf.loads(response.text.replace('\x00', ''))["items_game"]
    else:
        raise Exception("Failed to get items_game.txt.")
items_game=get_items_game()
modelmapping = {}
for key, data in items_game["items"].items():
    data=defaultdict(str,data)
    if len(data["model_player"])>0:
        modelmapping[data["item_class"]] = data["model_player"]
        modelmapping[data["item_type_name"].strip("#").lower()] = data["model_player"] # Three-Rune Sword fix because someone named it tf_weapon_bat instead of tf_weapon_sword in items_game.txt:items asdbgykuasdugvbiy
    if len(data["prefab"])>0 and data["prefab"]!="valve":
        prefab_data = items_game["prefabs"][data["prefab"].split(" ")[-1]]
        if "model_player" in prefab_data:
            modelmapping[data["name"].lower()] = prefab_data["model_player"]
    if "model_player_per_class" in data:
        modelmapping[data["item_class"]] = data["model_player_per_class"][list(data["model_player_per_class"].keys())[0]]
         

for key, data in items_game["prefabs"].items():
    if "model_player" in data and "item_class" in data:
        modelmapping[data["item_class"]] = data["model_player"]