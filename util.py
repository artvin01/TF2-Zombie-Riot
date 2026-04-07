import hashlib, os, datetime, json, vtf2img
from collections import defaultdict
from re import sub
from bs4 import BeautifulSoup, Formatter

# https://stackoverflow.com/questions/3768895/how-to-make-a-class-json-serializable
# Allow classes to define __json__ to be JSON serializable
from json import JSONEncoder
def wrapped_default(self, obj):
    return getattr(obj.__class__, "__json__", wrapped_default.default)(obj)
wrapped_default.default = JSONEncoder().default
JSONEncoder.original_default = JSONEncoder.default
JSONEncoder.default = wrapped_default
###

# --------------------------- ENV ---------------------------

# wavesets, npc, ...
DEBUG = []
if "DEBUG" in os.environ:
    DEBUG = [x.lower() for x in os.environ["DEBUG"].split(",")]

WAVESETS_FILESCOPE = []
if "FILESCOPE" in os.environ:
    WAVESETS_FILESCOPE = [x.lower() for x in os.environ["FILESCOPE"].split(",")]

WAVESETS_TYPESCOPE = []
if "TYPESCOPE" in os.environ:
    WAVESETS_TYPESCOPE = [x.title() for x in os.environ["TYPESCOPE"].split(",")]
else:
    WAVESETS_TYPESCOPE = ["Setup", "Custom"]#, "Betting", "Rogue"]

LOG_REDACT = None
if "LOG_REDACT" in os.environ:
    LOG_REDACT = os.environ["LOG_REDACT"]

print("DEBUG",DEBUG)
print("LOG_REDACT",LOG_REDACT)
print("wavesets:FILESCOPE",WAVESETS_FILESCOPE)
print("wavesets:TYPESCOPE",WAVESETS_TYPESCOPE)

# --------------------------- UTILITY FUNCTIONS ---------------------------

def music_modal(wave_entry_data):
    if type(wave_entry_data) == str:
        mfilename = wave_entry_data.replace("#","")
        title = mfilename
        artist = "?"
        try: int(wave_entry_data); return None # skip if not actual music entry e.g. "music_outro_duration"	"65"
        except ValueError: pass
    else:
        wave_entry_data = defaultdict(str,wave_entry_data)
        
        title = wave_entry_data["file"].replace("#","")
        if wave_entry_data["name"] != "": title = wave_entry_data["name"]
        
        artist = ""
        if wave_entry_data["author"] != "": artist = wave_entry_data["author"]
        
        mfilename = wave_entry_data["file"].replace("#","")
    
    file = f"https://raw.githubusercontent.com/artvin01/TF2-Zombie-Riot/refs/heads/master/sound/{mfilename}"
    return {
        "type": "music",
        "musicpre": "",
        "musictitle": title,
        "musicartist": artist,
        "filepath": file,
        "filename": mfilename,
        "file_exists": os.path.isfile(f"./TF2-Zombie-Riot/sound/{mfilename}")
    }

def cfgtoint(val,default:int=0):
    try:
        return int(val)
    except ValueError:
        return default

def cfgtofloat(val,default:float=0.0):
    try:
        return float(val)
    except ValueError:
        return default

def id_from_str(string):
    # https://stackoverflow.com/questions/49808639/generate-a-variable-length-hash
    return hashlib.shake_256(string.encode("utf-8")).hexdigest(2)

def html_img(url, alt):
    return f'<img src="{url}" alt="{alt}"/>'

def vtftoimg(vtf_path,png_path,alt): # turn an icon into 
    if not os.path.isfile("gh-pages/"+png_path): # if file already made
        vtf2img.Parser(vtf_path).get_image().save("gh-pages/"+png_path)
    return html_img("./"+png_path,alt)

def normalize_whitespace(str_):
    return " ".join(str_.split())


def absolute_link(filename, waveset):
    return f"{filename.split("/")[-1].replace(".cfg","")}{"_"*int(waveset!="")}{to_section_link(waveset)}"


def format_num(n):
    try:
        return format(int(n), ",").replace(",", ".")
    except ValueError: # 2ß00hp moment
        log(f"[format_num] Invalid input '{n}'!", "FAIL")
        return f"<span style=\"color:red;\">{n}</span>"


def to_section_link(str_):
    return sub(r'[^a-z0-9]', '', str_.lower())


def remove_multiline_comments(d): # Fixes the script interpreting the comment in npc_headcrabzombie.sp as actual data
    new_str = ""
    reading_comment = False
    for line in d.splitlines():
        if line == "/*": reading_comment=True
        if line == "*/": reading_comment=False
        if not reading_comment:
            new_str += line
    return new_str


def is_float(str_):
    try:
        float(str_)
        return True
    except ValueError:
        return False


def as_duration(str_):
    m, s = divmod(int(str_), 60)
    dm = "" if m == 0 else f"{m}m "
    ds = "" if s == 0 else f"{s}s "
    return f'{dm}{ds}'


def fill_template(template, context):
    for k,v in context.items():
        try:
            template=template.replace(k,v)
        except TypeError:
            log("[fill_template] Wrong key or value type!","FAIL")
            print("Key",k,type(k))
            print("Value",v,type(v))
            exit()
    return template

def debug(str_, category, color="OKGREEN"):
    if category in DEBUG: log(str_,color)


# Logging
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


"""pcolors = {
    "HEADER": (255,255,255),
    "OKBLUE": (12,109,240),
    "OKCYAN": (12,240,196),
    "OKGREEN": (53,240,12),
    "WARNING": (239,203,12),
    "FAIL": (255,0,0),
    "BOLD": (230,230,230),
    "UNDERLINE": (200,200,200)
}"""

LOGS = ""
def log(message, color="OKGREEN"):
    global LOGS
    time = f"[{datetime.datetime.now().strftime('%H:%M:%S')}] "
    pre = "[INFO] "
    if color == "WARNING": pre="[WARN] "
    if color == "FAIL": pre="[ERR] "
    if "OK" in color: pre="[LOG] "
    print(bcolors["FAINT"] + time + bcolors["ENDC"] + bcolors[color]  + pre + message + bcolors["ENDC"])
    if LOG_REDACT:
        LOGS += f"{time}{pre}{message.replace("\n","\\n")}\n".replace(LOG_REDACT,"***")


def read(filename):
    try:
        with open(filename, 'r') as f:
            return f.read()
    except FileNotFoundError:
        return None


def write(filename, val):
    if filename.endswith(".html"):
        soup=BeautifulSoup(val,features="html.parser")
        val=soup.prettify(formatter=Formatter("html5",indent=4))
    with open(filename, 'w+') as f:
        f.write(str(val))
    return True

# --------------------------- PHRASES ---------------------------

PHRASES = []

def get_key(k,silent=False,empty_on_fail=False):
    for phr in PHRASES:
        if k in phr:
            return phr[k]["en"]
    if not silent: log(f"'{k}' has no english translation!", "WARNING")
    if empty_on_fail:
        return ""
    else:
        return k