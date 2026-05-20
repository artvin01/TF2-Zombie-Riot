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

# --------------------------- ENV ---------------------------

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
    WAVESETS_TYPESCOPE = ["Setup", "Custom", "Rogue", "Betting", "Construction"]

LOCAL = os.path.isdir("gh-pages/icons/")
LOG_REDACT = None
if "LOG_REDACT" in os.environ:
    LOG_REDACT = os.environ["LOG_REDACT"]

print("DEBUG",DEBUG)
print("LOG_REDACT",LOG_REDACT)
print("wavesets:FILESCOPE",WAVESETS_FILESCOPE)
print("wavesets:TYPESCOPE",WAVESETS_TYPESCOPE)

# --------------------------- UTILITY ---------------------------

def music_modal(wave_entry_data: str | dict):
    """
    Turn config data into music modal data.
    """
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

def musicmodal_to_html(modal: dict):
    """
    Turn music modal data into HTML. 
    """
    context=modal.copy()
    file_exists = context.pop("file_exists")
    context["musictitle"]=apply_morecolors(context["musictitle"]).replace("|","") # remove pipes (only the case for red sun songs)
    context["musicartist"]=apply_morecolors(context["musicartist"])
    return fill_template(read(f"templates/music/music_modal{"_missing"*int(not file_exists)}.html"),context)

def cfgtoint(val: str, default: int=0):
    """
    Turn a config value into an int, returns default on fail.
    ```
    npc_hp = cfgtoint(defaultdict(str, entry_data)["hp"])  
    ' ' -> [default]  
    '200' -> 200  
    ```
    """
    try:
        return int(val)
    except ValueError:
        return default


def cfgtofloat(val: str, default: float=0.0):
    """
    Turn a config value into an float, returns default on fail.
    ```
    npc_delay = cfgtoint(entry)  
    'music_setup' -> [default]  
    '1.0' -> 1.0  
    ```
    """
    try:
        return float(val)
    except ValueError:
        return default


def id_from_str(string: str):
    # https://stackoverflow.com/questions/49808639/generate-a-variable-length-hash
    """
    Generate a length 4 hash given a string.
    """
    return hashlib.shake_256(string.encode("utf-8")).hexdigest(2)


def html_img(url: str, alt: str):
    """
    -> <img src="{url}" alt="{alt}"/>
    """
    return f'<img src="{url}" alt="{alt}"/>'


def vtftoimg(vtf_path: str, png_path: str, alt: str):
    """
    Converts `vtf` format to `png` format.
    -> <img src="{url}" alt="{alt}"/>
    """
    if not os.path.isfile("gh-pages/"+png_path): # if file already made
        vtf2img.Parser(vtf_path).get_image().save("gh-pages/"+png_path)
    return html_img("./"+png_path,alt)


def normalize_whitespace(string: str):
    return " ".join(string.split())


def absolute_link(filename: str, waveset: str):
    """
    Generates a name for a filename+waveset.
    absolute_link(".../classic.cfg", "Blitz's Army") -> "classic_blitz-s-army"
    """
    return f"{filename.split("/")[-1].replace(".cfg","")}{"_"*int(waveset!="")}{to_section_link(waveset)}"


def format_num(num: str):
    """
    "100000000" -> 100.000.000
    "2ß00" -> f"<span style="color:red;">2ß00</span>"
    """
    try:
        return format(int(num), ",").replace(",", ".")
    except ValueError:
        # raise ValueError(f"Invalid input '{num}'!")
        log(f"[format_num] Invalid input '{num}'!", "FAIL")
        return f"<span style=\"color:red;\">{num}</span>"


def to_section_link(string: str):
    """
    Replaces everything outside of A-Z a-z 0-9 to "-"
    "Blitz's Army" -> "blitz-s-army"
    """
    return sub(r'[^a-z0-9]', '-', string.lower())


def remove_multiline_comments(code: str): # Fixes the script interpreting the comment in npc_headcrabzombie.sp as actual data
    new_str = ""
    reading_comment = False
    for line in code.splitlines():
        if line == "/*": reading_comment=True
        if line == "*/": reading_comment=False
        if not reading_comment:
            new_str += line
    return new_str


def is_float(string: str):
    try:
        float(string)
        return True
    except ValueError:
        return False


def as_duration(seconds: int):
    """
    30s -> "30s"
    60s -> "1m"
    90s -> "1m 30s"
    """
    m, s = divmod(seconds, 60)
    dm = "" if m == 0 else f"{m}m "
    ds = "" if s == 0 else f"{s}s "
    return f'{dm}{ds}'


def fill_template(template: str, context: dict):
    """
    Replaces each context:key with its equivalent context:value in a template.
    For example:
    template = "Hello, $name!"
    context = {"$name": "Foobar"}
    -> "Hello, Foobar!"
    """
    for k,v in context.items():
        try:
            template=template.replace(k,v)
        except TypeError:
            log("[fill_template] Wrong key or value type!","FAIL")
            print("Key",k,type(k))
            print("Value",v,type(v))
            exit()
    return template

# --------------------------- LOGGING ---------------------------
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


def debug(string:str, category:str, color:str="OKGREEN"):
    if category in DEBUG: log(string,color)


LOGS = ""

def log(message:str, color:str="OKGREEN"):
    global LOGS
    time = f"[{datetime.datetime.now().strftime('%H:%M:%S')}] "
    pre = "[INFO] "
    if color == "WARNING": pre="[WARN] "
    if color == "FAIL": pre="[ERR] "
    if "OK" in color: pre="[LOG] "
    print(bcolors["FAINT"] + time + bcolors["ENDC"] + bcolors[color]  + pre + message.replace("\n","\\n") + bcolors["ENDC"])
    if LOG_REDACT:
        LOGS += f"{time}{pre}{message.replace("\n","\\n")}\n".replace(LOG_REDACT,"***")


# --------------------------- CORE ---------------------------
def read(filename:str):
    try:
        # Windows-specific fix to: https://stackoverflow.com/questions/9233027/unicodedecodeerror-charmap-codec-cant-decode-byte-x-in-position-y-character
        # no idea if applying encoding="utf-8" everywhere changes anything, better be safe
        if os.name == 'nt':
            with open(filename, 'r', encoding="utf-8") as f:
                return f.read()
        else:
            with open(filename, 'r') as f:
                return f.read()
    except FileNotFoundError:
        return None


def write(filename:str, val:str):
    if filename.endswith(".html"):
        soup=BeautifulSoup(val,features="html.parser")
        val=soup.prettify(formatter=Formatter("html5",indent=4))
    with open(filename, 'w+') as f:
        f.write(val)
    return True

# --------------------------- PHRASES ---------------------------

PHRASES = []

def get_key(key:str,silent:bool=False,empty_on_fail:bool=False):
    silent = silent or "decompile" in DEBUG
    for phrase in PHRASES:
        if key in phrase:
            return phrase[key]["en"]
    if not silent: log(f"'{key}' has no english translation!", "WARNING")
    if empty_on_fail:
        return ""
    else:
        return key

# --------------------------- MORECOLORS SUPPORT ---------------------------

MORECOLORS_JSON = json.loads(read("gh-pages/static/morecolors.json"))

def apply_morecolors(string:str):
    new=f"<span>{string}</span>"
    has_replaced = False
    for colorname in MORECOLORS_JSON.keys():
        new=new.replace(f"{{{colorname}}}", f'</span><span class="mc_{colorname}">')
        if f"{{{colorname}}}" in string: has_replaced=True
    new=new.replace("<span></span>","") # remove empty divs
    if has_replaced: return new.replace("-"," - ")
    return string

def divfornewline(string:str):
    """
    NOTE: Doesn't take \\\\n
    """
    return f"<div>{string.replace("\n","</div>\n<div>")}</div>\n"