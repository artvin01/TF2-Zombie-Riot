import os
from time import time
from importlib import import_module
MODULES = {
    "static": {"file": "modules.static"},
    "phrase": {"file": "modules.phrase"},
    "wavesets": {
        "file": "modules.wavesets",
        "paths": [
            "gh-pages/embed",
            "gh-pages/repo_img",
            "gh-pages/wavesets"
        ]
    },
    "npcs": {"file": "modules.npcs"},
    "music": {
        "file": "modules.music",
        "paths": ["gh-pages/data"]
    },
    "items": {
        "file": "modules.weapon",
        "paths": ["gh-pages/data"]
    },
    "skilltree": {"file": "modules.skilltree"},
    "statusfx": {
        "file": "modules.status_effects",
        "paths": ["gh-pages/data"]
    }
}
SCOPE = [x.lower() for x in os.environ["SCOPE"].split(",") if (x.lower() in MODULES.keys())] if "SCOPE" in os.environ else list(MODULES.keys())
if "phrase" not in SCOPE: # always required.
    SCOPE.append("phrase")
print("SCOPE", SCOPE)

for item in SCOPE:
    module_data = MODULES[item]
    if "paths" in module_data:
        for dir in module_data["paths"]:
            os.makedirs(dir,exist_ok=True)
    print(f"[{item}] ========================================")
    start = time()
    import_module(module_data["file"])
    print(f"[{item}] Took {time()-start}s")
