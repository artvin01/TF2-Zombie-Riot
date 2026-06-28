# Check if all cfg files load correctly
import traceback
import vdf
import pathlib
import sys
import datetime

bcolors = {
    "OKGREEN": '\033[92m',
    "FAIL": '\033[91m',
    "ENDC": '\033[0m',
    "FAINT": '\033[2m',
}
def log(message:str, color:str="OKGREEN"):
    time = f"[{datetime.datetime.now().strftime('%H:%M:%S')}] "
    pre = "[LOG] " if "OK" in color else ("[WARN] " if color=="WARNING" else ("[ERR] " if color == "FAIL" else "[INFO] "))
    print(bcolors["FAINT"] + time + bcolors["ENDC"] + bcolors[color]  + pre + message + bcolors["ENDC"])
def read(filename:str)->str:
    with open(filename, 'r') as f:
        return f.read()

paths = {
    ".": "**/*.txt",
    "./": "**/*.cfg",
}
exclude = [
    "venv",
    "LICENSE",
    "Developer Commentary - Laboratories.txt",
    "vehicles", # temp
    # Local testing
    "gh-pages"
]
had_errors = False
for path,filter_ in paths.items():
    for CFG in pathlib.Path(path).glob(filter_):
        if not any(x in str(CFG) for x in exclude) and "/" in str(CFG):
            try:
                pre,c = "✓","OKGREEN"
                vdf.loads(read(CFG)) # type: ignore[w]
                ex = ""
            except SyntaxError:
                pre,c = "✗","FAIL"
                ex = "\n"+traceback.format_exc()
                had_errors = True
            log(f"{pre} {CFG}{ex}",c)
sys.exit(int(had_errors))
