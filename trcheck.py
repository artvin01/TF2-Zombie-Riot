# Check if all cfg files load correctly
import traceback, vdf, pathlib, sys, datetime

bcolors = {
    "HEADER": '\033[95m',
    "OKBLUE": '\033[94m',
    "OKCYAN": '\033[96m',
    "OKGREEN": '\033[92m',
    "WARNING": '\033[93m',
    "FAIL": '\033[91m',
    "ENDC": '\033[0m',
    "BOLD": '\033[1m',
    "UNDERLINE": '\033[4m',
    "FAINT": '\033[2m',
}
def log(message, color="OKGREEN"):
    time = f"[{datetime.datetime.now().strftime('%H:%M:%S')}] "
    pre = "[INFO] "
    if color == "WARNING": pre="[WARN] "
    if color == "FAIL": pre="[ERR] "
    if "OK" in color: pre="[LOG] "
    print(bcolors["FAINT"] + time + bcolors["ENDC"] + bcolors[color]  + pre + message + bcolors["ENDC"])
def read(filename):
    try:
        with open(filename, 'r') as f:
            return f.read()
    except FileNotFoundError:
        return None

paths = {
    "./TF2-Zombie-Riot/addons/sourcemod/translations/": "**/*.txt",
    "./TF2-Zombie-Riot/": "**/*.cfg",
}
had_errors = False
for path,filter_ in paths.items():
    for CFG in pathlib.Path(path).glob(filter_):
        try:
            pre,c = "✓","OKGREEN"
            vdf.loads(read(CFG))
            ex = ""
        except:
            pre,c = "✗","FAIL"
            ex = "\n"+traceback.format_exc()
            had_errors = True
        log(f"{pre} {CFG}{ex}",c)
sys.exit(int(had_errors))