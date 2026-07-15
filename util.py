import hashlib
import os
import datetime
import json
import vtf2img
from collections import defaultdict
from re import sub
from bs4 import BeautifulSoup
from bs4.formatter import Formatter
from ruamel.yaml import YAML
type TypeSourceObject = list[list[int] | str | int ]

# https://stackoverflow.com/questions/3768895/how-to-make-a-class-json-serializable
# Allow classes to define __json__ to be JSON serializable
from json import JSONEncoder # noqa: E402
def wrapped_default(self, obj): # type: ignore[all]
    return getattr(obj.__class__, "__json__", wrapped_default.default)(obj) # type: ignore[all]
wrapped_default.default = JSONEncoder().default # type: ignore[all]
JSONEncoder.original_default = JSONEncoder.default # type: ignore[all]
JSONEncoder.default = wrapped_default # type: ignore[all]

# --------------------------- ENV ---------------------------

DEBUG = [x.lower() for x in os.environ["DEBUG"].split(",")] if "DEBUG" in os.environ else []
WAVESETS_FILESCOPE = [x.lower() for x in os.environ["FILESCOPE"].split(",")] if "FILESCOPE" in os.environ else []
WAVESETS_TYPESCOPE = [x.title() for x in os.environ["TYPESCOPE"].split(",")] if "TYPESCOPE" in os.environ else ["Setup", "Custom", "Rogue", "Betting", "Construction"]

print("DEBUG",DEBUG)
print("wavesets:FILESCOPE",WAVESETS_FILESCOPE)
print("wavesets:TYPESCOPE",WAVESETS_TYPESCOPE)

# --------------------------- UTILITY ---------------------------

def music_modal(wave_entry_data: str | dict[str,str]) -> dict[str,str|bool] | None:
    """
    Turn config data into music modal data.
    """
    if type(wave_entry_data) is str:
        mfilename = wave_entry_data.replace("#","")
        title = mfilename
        artist = "?"
        try:
            int(wave_entry_data)
            return None # skip if not actual music entry e.g. "music_outro_duration"	"65"
        except ValueError:
            pass
    else:
        wave_entry_data = defaultdict(str,wave_entry_data) # type: ignore[w]

        title = wave_entry_data["file"].replace("#","")
        if wave_entry_data["name"] != "":
            title = wave_entry_data["name"]

        artist = ""
        if wave_entry_data["author"] != "":
            artist = wave_entry_data["author"]

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

def musicmodal_to_html(modal: dict[str,str]) -> str:
    """
    Turn music modal data into HTML.
    """
    context=modal.copy()
    file_exists = context.pop("file_exists")
    context["musictitle"] = apply_morecolors(context["musictitle"]).replace("|","") # remove pipes (only the case for red sun songs)
    context["musicartist"] = apply_morecolors(context["musicartist"])
    if "source" in context:
        context["SRC"] = html_src(modal["source"])
        del context["source"]
    else:
        log("Modal does not have 'source' set!","WARNING")
        log(json.dumps(modal,indent=2),"FAIL")
        context["SRC"] = "?"
    return fill_template(read(f"templates/music/music_modal{"_missing"*int(not file_exists)}.html"),context)

def cfgtoint(val: str, default: int=0) -> int:
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


def cfgtofloat(val: str, default: float=0.0) -> float:
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


def id_from_str(string: str, hexdigest: int=2) -> str:
    # https://stackoverflow.com/questions/49808639/generate-a-variable-length-hash
    """
    Generate a length 4 hash given a string.
    """
    return hashlib.shake_256(string.encode("utf-8")).hexdigest(hexdigest)


def html_img(url: str, src: TypeSourceObject = ("?",-1)) -> str:
    """
    -> <img src="{url}" data-src="{html_src(src)}"/>
    """
    return f'<img src="{url}" data-src="{html_src(src)}"/>'


def vtftoimg(vtf_path: str, png_path: str) -> str:
    """
    Converts `vtf` format to `png` format.
    -> <img src="{url}" alt="{alt}"/>
    """
    if not os.path.isfile("gh-pages/"+png_path): # if file already made
        vtf2img.Parser(vtf_path).get_image().save("gh-pages/"+png_path)  # type: ignore[w]
    return f"./{png_path}"


def normalize_whitespace(string: str) -> str:
    return " ".join(string.split())


def absolute_link(filename: str, waveset: str) -> str:
    """
    Generates a name for a filename+waveset.
    absolute_link(".../classic.cfg", "Blitz's Army") -> "classic_blitz-s-army"
    """
    return f"{filename.split("/")[-1].replace(".cfg","")}{"_"*int(waveset!="")}{to_section_link(waveset)}"


def format_num(num: str) -> str:
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


def to_section_link(string: str) -> str:
    """
    Replaces everything outside of A-Z a-z 0-9 to "-"
    "Blitz's Army" -> "blitz-s-army"
    """
    return sub(r'[^a-z0-9]', '-', string.lower())


def remove_multiline_comments(code: str, newline:bool=False) -> str: # Fixes the script interpreting the comment in npc_headcrabzombie.sp as actual data
    new_str = ""
    reading_comment = False
    for line in code.splitlines():
        if line == "/*":
            reading_comment=True
        if line == "*/":
            reading_comment=False
        if not reading_comment:
            new_str += line
            if newline:
                new_str += "\n"
    return new_str


def is_float(string: str) -> bool:
    try:
        float(string)
        return True
    except ValueError:
        return False


def as_duration(seconds: int) -> str:
    """
    30s -> "30s"
    60s -> "1m"
    90s -> "1m 30s"
    """
    m, s = divmod(seconds, 60)
    dm = "" if m == 0 else f"{m}m "
    ds = "" if s == 0 else f"{s}s "
    return f'{dm}{ds}'


def fill_template(template: str, context: dict[str,str]) -> str:
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
    if category in DEBUG:
        log(string,color)


LOGS = ""
def log(message:str, color:str="OKGREEN"):
    global LOGS
    time = f"[{datetime.datetime.now().strftime('%H:%M:%S')}] "
    pre = "[INFO] "
    if color == "WARNING":
        pre="[WARN] "
    if color == "FAIL":
        pre="[ERR] "
    if "OK" in color:
        pre="[LOG] "
    print(bcolors["FAINT"] + time + bcolors["ENDC"] + bcolors[color]  + pre + message.replace("\n","\\n") + bcolors["ENDC"])


# --------------------------- CORE ---------------------------
def read(filename:str) -> str:
    # Windows-specific fix to: https://stackoverflow.com/questions/9233027/unicodedecodeerror-charmap-codec-cant-decode-byte-x-in-position-y-character
    # no idea if applying encoding="utf-8" everywhere changes anything, better be safe
    if os.name == 'nt':
        with open(filename, 'r', encoding="utf-8") as f:
            return f.read()
    else:
        with open(filename, 'r') as f:
            return f.read()

def readlines(filename:str) -> str:
    # Windows-specific fix to: https://stackoverflow.com/questions/9233027/unicodedecodeerror-charmap-codec-cant-decode-byte-x-in-position-y-character
    # no idea if applying encoding="utf-8" everywhere changes anything, better be safe
    if os.name == 'nt':
        with open(filename, 'r', encoding="utf-8") as f:
            return "".join(f.readlines())
    else:
        with open(filename, 'r') as f:
            return "".join(f.readlines())


def write(filename:str, val:str):
    """
    # for debugging (increases generation time)
    if filename.endswith(".html"):
        soup=BeautifulSoup(val,features="html.parser")
        val=soup.prettify(formatter=Formatter("html5",indent=4))
    """
    with open(filename, 'w+') as f:
        f.write(val)

# --------------------------- PHRASES ---------------------------

PHRASES: list[dict[str,str]] = []

yaml=YAML(typ='safe')
with open("./config/phrases.yml",'r') as file:
    PHRASES_FILES = yaml.load(file) # type: ignore[w]

def get_key(key:str,silent:bool=False,empty_on_fail:bool=False) -> str:
    silent = silent or "decompile" in DEBUG
    for phrase in PHRASES:
        if key in phrase:
            return phrase[key]["en"]
    if not silent:
        log(f"'{key}' has no english translation!", "WARNING")
    if empty_on_fail:
        return ""
    else:
        return key

# --------------------------- MORECOLORS SUPPORT ---------------------------

MORECOLORS_JSON = json.loads(read("gh-pages/static/data/morecolors.json"))

def apply_morecolors(string:str):
    new=f"<span>{string}</span>"
    has_replaced = False
    for colorname in MORECOLORS_JSON.keys():
        new=new.replace(f"{{{colorname}}}", f'</span><span class="mc_{colorname}">')
        if f"{{{colorname}}}" in string:
            has_replaced=True
    new=new.replace("<span></span>","") # remove empty divs
    if has_replaced:
        return new.replace("-"," - ")
    return string

def divfornewline(string:str):
    """
    NOTE: Doesn't take \\\\n
    """
    return f"<div>{string.replace("\n","</div>\n<div>")}</div>\n"

# --------------------------- SOURCE INSPECTOR ---------------------------

def get_sources(files: dict[str,str], variables: dict[str,str | int]) -> dict[str,dict[str,str]]:
    """
    Get a source dictionary showing where content is located in a file.
    Only use this if you cannot add sources in the parsing process itself!
    files:
        {
            file_url:str : file_content:str,
            [...]
        }
    variables:
        {
            variable_name:str : value:str|int
            [...]
        }

    -> {
            variable_name:str : {
                filename:str : {
                    "file_url": file_url:str,
                    "refs": [10,20,30,...]
                }
                [...]
            }
            [...]
        }
    """
    found: dict[str,dict[str,str]] = defaultdict(dict)

    for file_url, file_content in files.items():
        for variable_name,value in variables.items():
            found[variable_name][file_url] = get_refs(file_content, value)

    return found

def get_refs(content: str, value: str | int, negative_on_fail:bool=False, print_:bool=False) -> list[int]:
    if print_:
        write("debug.json", json.dumps(content.split("\n"),indent=2))
    result: list[int] = [i+1 for i,line in enumerate(content.split("\n")) if str(value) in line]
    if len(result) > 0:
        return result
    elif negative_on_fail:
        return [-1]
    else:
        raise ValueError(f"Could not find '{value}' in content!")

#  util.get_key_src(desc_key, negative_on_fail=True)
def get_key_src(key:str) -> tuple[str,int]: # part of phrases
    for idx, phrase in enumerate(PHRASES):
        if key in phrase:
            # phrase[key]["en"]
            filename = f"./TF2-Zombie-Riot/addons/sourcemod/translations/{PHRASES_FILES[idx]}"
            filedata = read(filename)
            return (filename.replace("./TF2-Zombie-Riot/",""), get_refs(filedata,key,negative_on_fail=True)[0])
    return ("?",-1)

def html_src(src_obj: TypeSourceObject):
    if type(src_obj[1]) is list:
        return f"{src_obj[0]}#L{src_obj[1][0]}-L{src_obj[1][1]}"
    else:
        return f"{src_obj[0]}#L{src_obj[1]}"
