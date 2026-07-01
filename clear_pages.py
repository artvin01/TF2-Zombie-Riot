from shutil import rmtree
from os import listdir, remove
from os.path import isdir

r = [
    "gh-pages/data",
    "gh-pages/docs",
    "gh-pages/embed",
    "gh-pages/icons",
    "gh-pages/premedia_icons",
    "gh-pages/static",
    "gh-pages/wavesets",
    "gh-pages/repo_img"
]
[rmtree(d) for d in r if isdir(d)]

for file in listdir("gh-pages/"):
    if file.endswith(".ico") or file.endswith(".html"):
        remove(f"gh-pages/{file}")
