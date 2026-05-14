# tf2_zr_wikigen
*https://artvin01.github.io/TF2-Zombie-Riot/*  
Automatic encyclopedia generator for https://github.com/artvin01/TF2-Zombie-Riot.  
Icon source: https://github.com/feathericons/feather  

# Running locally
## Prerequisites 
- [Open Asset Import Library (assimp)](https://github.com/assimp/assimp/)  

By default, only custom ZR models are used. To include TF2 models, unpack the models directory of `tf2_misc_dir.vpk` into `models/models/`. You don't really need to do this since the generated icons of those models are already shipped in `gh-pages/tf_icons/`.  
The file structure should look like this:  
```
└── models/
    └── models/
        ├── bots
        ├── buildables
        ├── class_menu
        ├── crafting
        └── [...]
```

## Installation
Recommended Python version: 3.14
```bash
git clone https://github.com/artvin01/TF2-Zombie-Riot -b wiki_gen; cd TF2-Zombie-Riot
python -m venv venv
git clone https://github.com/artvin01/TF2-Zombie-Riot --depth 1
# Linux
./venv/bin/pip install -r requirements.txt
# Windows
venv\Scripts\pip.exe install -r requirements.txt
```
## (optional) Decompiling models for weapon icon generation
### Linux
Dependencies: wine, unzip
```bash
wget https://github.com/mrglaster/Source-models-decompiler-cmd/releases/download/Update/CrowbarDecompiler.1.1.zip
unzip CrowbarDecompiler.1.1.zip
./venv/bin/python modules/weapon-decompile.py
```
### Windows
If you *only* want to decompile on Windows, use `requirements_decompile.txt` for the above installation process.
```powershell
Invoke-Webrequest https://github.com/mrglaster/Source-models-decompiler-cmd/releases/download/Update/CrowbarDecompiler.1.1.zip -OutFile CrowbarDecompiler.1.1.zip
Expand-Archive .\CrowbarDecompiler.1.1.zip .\
venv\Scripts\python.exe modules\weapon-decompile.py
```
Expected output:
```
├── decompiled/ - decompiled ZR models
│   └── .smd,.qc,.obj,.mtl,.json
└── tf_decompiled/ - decompiled TF2 models (if present)
    └── .smd,.qc,.obj,.mtl,.json
```

## Generating the Wiki
**Environment Variables**
- `SCOPE=wavesets,npcs,items,music,skilltree`: Limit which parts of the wiki are generated.  
- `DEBUG=npcs,wavesets,weaponpap,weaponicon`: Show more info for specified category.  
  Waveset-specific config:  
- `FILESCOPE`: Limit waveset data generation to a specific config file, e.g. `FILESCOPE=maps/zr_matrix.cfg`.  
- `TYPESCOPE=Setup,Custom,Rogue,Betting,Construction`: Limit waveset data generation to a specific type of config file.  

To generate the wiki, simply run
```bash
# Linux
./venv/bin/python main.py
# Windows (untested!)
venv\Scripts\python.exe main.py
```
All generated files will be put in `gh-pages/`. If you want to know which of those aren't automatically generated, see the `.gitignore`.

# TODO
- [x] Waveset data
  - [ ] Special wavesets
    - [ ] ZR: Construction
        - [ ] Construction 2 (partial support)
- [x] NPC data
  - [ ] Better NPC data parsing
- [x] Item data
  - [ ] Weapon CSS rework
    - [x] Basic weapon list
    - [ ] Weapon Enhancements (+ Icons)
    - [ ] Weapon Kits
    - [ ] Search filters
- [x] Skilltree data