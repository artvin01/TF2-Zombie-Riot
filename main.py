import os
from time import time
from importlib import import_module
# any module that uses util.py requires static module (morecolors support)
MODULES = {
    "static": {"file": "modules.static"},
    "phrase": {"file": "modules.phrase"},
    "wavesets": {
        "file": "modules.wavesets",
        "dependencies": ["static", "phrase"],
        "paths": [
            "gh-pages/repo_img",
            "gh-pages/wavesets"
        ]
    },
    "npcs": {
        "file": "modules.npcs",
        "dependencies": [
            "static",
            "phrase",
            "wavesets"
        ]
    },
    "music": {
        "file": "modules.music",
        "dependencies": [
            "static",
            "wavesets"
        ],
        "paths": ["gh-pages/data"]
    },
    "items": {
        "file": "modules.weapon",
        "dependencies": [
            "static",
            "phrase"
        ],
        "paths": ["gh-pages/data"]
    },
    "skilltree": {
        "file": "modules.skilltree",
        "dependencies": [
            "static",
            "phrase"
        ],
        "paths": ["gh-pages/data"]
    },
    "statusfx": {
        "file": "modules.status_effects",
        "dependencies": [
            "static",
            "phrase"
        ],
        "paths": ["gh-pages/data"]
    }
}
SCOPE = [x.lower() for x in os.environ["SCOPE"].split(",") if (x.lower() in MODULES.keys())] if "SCOPE" in os.environ else list(MODULES.keys())
print("SCOPE", SCOPE)

def s_print(str_: str, silent: bool):
    if not silent:
        print(str_)

def exec_module(module_name: str, silent: bool = False):
    s_print(f"[{module_name}] ========================================", silent)
    module_data = MODULES[module_name]
    if "dependencies" in module_data:
        s_print(f"[{module_name}] Resolving dependencies",silent)
        for dep in module_data["dependencies"]:
            if dep not in SCOPE:
                print(f"[{module_name}] Importing {dep}")
                SCOPE.append(dep)
                exec_module(dep, True)
    if "paths" in module_data:
        for dir in module_data["paths"]:
            os.makedirs(dir,exist_ok=True)
    s_print(f"[{module_name}] Importing module",silent)
    start = time()
    import_module(module_data["file"])
    s_print(f"[{module_name}] Took {time()-start}s",silent)

for item in SCOPE.copy():
    exec_module(item)
