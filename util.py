import hashlib, os, datetime
from collections import defaultdict
from re import sub

# https://stackoverflow.com/questions/3768895/how-to-make-a-class-json-serializable
# Allow classes to define __json__ to be JSON serializable
from json import JSONEncoder
def wrapped_default(self, obj):
    return getattr(obj.__class__, "__json__", wrapped_default.default)(obj)
wrapped_default.default = JSONEncoder().default
JSONEncoder.original_default = JSONEncoder.default
JSONEncoder.default = wrapped_default
###

# Use ' ' for spacing in markdown

# wavesets, npc, ...
CATEGORIES = []
if "DEBUG" in os.environ:
    CATEGORIES = [x.lower() for x in os.environ["DEBUG"].split(",")]

SCOPE = []
if "SCOPE" in os.environ:
    SCOPE = [x.lower() for x in os.environ["SCOPE"].split(",")]
else:
    #SCOPE = ["wavesets", "items", "skilltree"]
    SCOPE = ["wavesets", "items"]

WAVESETS_FILESCOPE = []
if "FILESCOPE" in os.environ:
    WAVESETS_FILESCOPE = [x.lower() for x in os.environ["FILESCOPE"].split(",")]

WAVESETS_TYPESCOPE = []
if "TYPESCOPE" in os.environ:
    WAVESETS_TYPESCOPE = [x.title() for x in os.environ["TYPESCOPE"].split(",")]
else:
    WAVESETS_TYPESCOPE = ["Setup", "Custom"]#, "Betting", "Rogue"]

print("CATEGORIES",CATEGORIES)
print("SCOPE",SCOPE)
print("FILESCOPE",WAVESETS_FILESCOPE)
print("TYPESCOPE",WAVESETS_TYPESCOPE)

def id_from_str(string):
    # https://stackoverflow.com/questions/49808639/generate-a-variable-length-hash
    return hashlib.shake_256(string.encode("utf-8")).hexdigest(2)

def md_img(url, alt, width=16):
    #return f'<img src="{url}" alt="{alt}" width="{width}"/>'
    return f'<img src="{url}" width="{width}"/>'


def normalize_whitespace(str_):
    return " ".join(str_.split())


def absolute_link(filename, waveset):
    return f"{filename.split("/")[-1]}_{to_section_link(waveset)}"


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
        template=template.replace(k,v)
    return template


def debug(str_, category, color="OKGREEN"):
    if category in CATEGORIES: log(str_,color)


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


def write(filename, val):
    with open(filename, 'w+') as f:
        f.write(str(val))
    return True

BUILTIN_IMG = "https://raw.githubusercontent.com/squarebracket-s/tf2_zr_wikigen/refs/heads/main/builtin_img/"
ICON_DOWNLOAD = md_img(BUILTIN_IMG+"download.svg", "download")
ICON_X_SQUARE = md_img(BUILTIN_IMG+"x-square.svg","cross")
ICON_MUSIC = md_img(BUILTIN_IMG+"music.svg","music")