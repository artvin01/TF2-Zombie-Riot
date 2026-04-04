# Parse all NPCs & Wavesets (Normal & Custom, wavesets like Construction are yet to be supported.)
import util, os, subprocess, pathlib, json, time
import embed, modules.shared
from collections import defaultdict
from keyvalues1 import KeyValues1

PROPERTY_MAPPINGS = {
    "is_boss": "Boss",
    "is_outlined": "Outline",
    "force_scaling": "ForceScaling",
    "is_health_scaling": "HealthScaling",
    "is_immune_to_nuke": "NukeImmunity"
}

MULTIPLIER_MAPPINGS = {
    "extra_melee_res": "☛",
    "extra_ranged_res": "➶",
    "extra_speed": "↗",
    "extra_damage": "☖",
    "extra_size": "⤡",
}

                
waveset_cache = {}
def parse():
    generated_files = {
        "npcs.md": "NPCs.md",
        "home.md": "Home.md",
        "sidebar.md": "_Sidebar.md"
    }

    def parse_all_npcs():
        npc_by_file = {}
        npc_by_category = {}
        for file in pathlib.Path(PATH_NPC).glob('**/*'):
            if os.path.isfile(file.absolute()):
                npc_obj = modules.shared.NPC(str(file.absolute()))
                if not npc_obj.hidden:
                    plugin_name = npc_obj.plugin
                    if type(plugin_name) == list:
                        for i,pn in enumerate(plugin_name):
                            dummy = modules.shared.NPC_Dummy(npc_obj)
                            dummy.category = npc_obj.category[min(len(npc_obj.category)-1,i)]
                            dummy.plugin = npc_obj.plugin[min(len(npc_obj.plugin)-1,i)]
                            dummy.flags = npc_obj.flags[min(len(npc_obj.flags)-1,i)]
                            npc_by_file[pn] = dummy
                            dummy.filename = pn
                            if dummy.category not in npc_by_category: npc_by_category[dummy.category]=[]
                            npc_by_category[dummy.category].append(dummy)
                    else:                    
                        npc_by_file[plugin_name] = npc_obj
                        npc_obj.filename = plugin_name
                        if npc_obj.category not in npc_by_category: npc_by_category[npc_obj.category]=[]
                        npc_by_category[npc_obj.category].append(npc_obj)

        if "npcs" in util.CATEGORIES:
            util.write("npc_data.json",json.dumps(npc_by_file,indent=2))

        return npc_by_file, npc_by_category
    
    def parse_default_cash():
        return util.normalize_whitespace(util.read("TF2-Zombie-Riot/addons/sourcemod/scripting/zombie_riot/zr_core.sp").split("public const int DefaultWaveCash[] =\n{\n")[1].split("\n};")[0]).split(", ")
    

    def unique_enemy_delays(w):
        # Make each wave delay unique as not to lose out on info (for example if 2 enemies have same wave delay)
        # https://stackoverflow.com/questions/41941116/replace-each-occurrence-of-sub-strings-in-the-string-with-randomly-generated-val
        space = "		"
        for i in range(0,301):
            delay_str = f'{i/10:.1f}'
            delay_count = w.count(delay_str)
            w = w.replace("{","{{").replace("}","}}") # double curly brackets get ignored by .format
            w = w.replace(f'{space}"{delay_str}"', space+'"{}"')
            w = w.format(*(" "*i + delay_str for i in range(delay_count)))
        return w
    
    def get_npc(plugin, data):
        npc_data = NPCS_BY_FILENAME[plugin]
        npc_cat = f"Category: {npc_data.category}  \n" if npc_data.category != "" else ""
        if "0" not in npc_data.flags and "-1" not in npc_data.flags:
            npc_flags = "Flags: "
            dflags = ", ".join([modules.shared.FLAG_MAPPINGS[item] for item in npc_data.flags])
            npc_flags += dflags + "  \n"
        else:
            npc_flags = ""
        return {
            "plugin": plugin,
            "flags": npc_flags,
            "description": npc_data.description
        }

    def parse_wave(wave_idx, wave_data, auto_wave_cash, is_betting=False, force=False):
        output = []
        has_cash_entry = False

        for wave_entry in wave_data:
            wave_entry_data = wave_data[wave_entry]
            try:
                float(wave_entry)
            except ValueError:
                if wave_entry.startswith("music_"):
                    if (mdata := util.music_modal(wave_entry_data)):
                        output.append(mdata)
                
                if wave_entry == "xp":
                    output.append({
                        "type": "info",
                        "text": f"Wave XP: {wave_entry_data}"
                    })

                if wave_entry == "cash":
                    has_cash_entry = True
                    output.append({
                        "type": "info",
                        "text": f"Wave cash: <span class=\"money\">{wave_entry_data}</span>"
                    })
                
                if wave_entry == "setup":
                    output.append({
                        "type": "info",
                        "text": f"Setup time: {util.as_duration(wave_entry_data)}"
                    })
                continue
            
            """
            ? - use unknown
            // comment from TF2-Zombie-Riot code
            ( ) own comment

            Builtin - accounted for on its own
            Flag - self explanatory
            Special Flag - in flag list but accounted for on its own
            Mult - multipliers (melee res, ranged res, speed, dmg), after flag

            # Wave
            Int count => Builtin //how many of that npc spawns. note: on max player counts this number is multiplied by 4. on 4 playercount, its just this number.
            Float delay => Hidden //setting this to "0.0" will make it wait for this npc group to die before spawning the next npc group.

            # NPC
            Int health => Hidden (apparently it's inaccurate)
            Bool is_boss => Flag //if a npc has this, they will get outlined, bonus damage, and their health scales.
            Bool force_scaling => Flag
            Float waiting_time_give ?
            Bool does_not_scale (true if count <= 0) => Flag ?
            Bool ignore_max_cap (ignore npc count and spawn forever => Support Type) 
            Bool is_outlined => Flag //if the npc is outlined.
            Bool is_health_scaling => Flag //if the npc's health should scale.
            Bool is_immune_to_nuke => Flag //if immune to the nuke powerup drop.
            Bool is_static ?
            Int team_npc (default 3) => Support Type (not in PROPERTY_MAPPINGS) //the team the npc is on. 999 = free for all. 2 = red team, aka ally. (NOTE: red team shown in support section of wave)
            Float cash => Hidden //how much cash this npc drops when it dies, note: this is now mostly redundant since raidmode can automatically calculate this. (thank god). full cash gotten = this*count.
            
            ％
            Float extra_melee_res => ☛ Mult //dmg is multiplied by this. 1.0 = 0% dmg resistance, 2.0 = npc takes 2x damage. 0.5 = npc takes half dmg.
            Float extra_ranged_res => ➶ Mult
            Float extra_speed => ↗ Mult (unsure about this icon) //multiplies the base speed of the npc by this much.
            Float extra_damage => ☖ Mult
            Float extra_size => ⤡ Mult //size multi.
            Float extra_thinkspeed ? (whatever this does is probably not important)

            Int danger_level ? (Only used in challenges/freeplay/advanced.cfg)
            String custom_name TODO -> Property
            (
            String data => Builtin (variations of the same NPC)
            String spawn ?
            )
            """
            count = "<span style=\"font-weight:850;\">1</span>" if wave_entry_data["count"] == "0" else wave_entry_data["count"]
            
            if wave_entry_data["plugin"] in NPCS_BY_FILENAME:
                npc_data = NPCS_BY_FILENAME[wave_entry_data["plugin"]]
            else:
                npc_data = None
                assert force

            try:
                npc_name = npc_data.name
            except AttributeError:
                npc_name = wave_entry_data["plugin"]

            # Prefix data
            dd = defaultdict(str, wave_entry_data)
            extra_info = ""
            npc_name_prefix = ""
            if npc_data and len(dd["data"])>0 and npc_data.has_prefix_logic:
                """
                prefix logic:
                    bool carrier = data[0] == 'R';
                    bool elite = !carrier && data[0];

                usually accompanied with data like:
                    "Regressed"
                    "Elite"

                so just add it before the npc name if npc has that logic
                """
                npc_name_prefix += wave_entry_data["data"].capitalize()
            
            # Show NPC Flags
            display_name = npc_name
            desc = ""
            if npc_data:
                for flag in npc_data.flags:
                    if flag != "0" and flag != "-1":
                        extra_info += f" {modules.shared.FLAG_MAPPINGS[flag]}"

                # Get icon
                image = modules.shared.get_npc_icon(npc_data.icon)
                
                if npc_data.category != "Type_Hidden":
                    desc = "<div class=\"flex_break\"></div>\n"+get_npc(wave_entry_data["plugin"], {"name": npc_name, "image": image})["description"]
            else:
                image = "" if "wavesets" not in util.CATEGORIES else util.md_img("./builtin_img/missing.png","E")
                
            for property_, val in PROPERTY_MAPPINGS.items():
                if property_ in wave_entry_data:
                    if wave_entry_data[property_] == "1":
                        extra_info += f" {val}"

            for multiplier, char in MULTIPLIER_MAPPINGS.items():
                if multiplier in wave_entry_data:
                    percent = float(wave_entry_data[multiplier])*100

                    percent_text = f"{percent:.2f}"
                    if float(percent_text).is_integer():
                        percent_text = int(percent)

                    extra_info += f" {char} {percent_text}％"
            
            # waves.sp line 4165 if(data.Is_Boss < 2 && (support || data.ignore_max_cap || data.Is_Static || data.Team == TFTeam_Red))

            # Add npc to wave data output for waves.js to be parsed
            # TODO use flags for different icon looks
            output.append(
                {
                    "type": "npc",
                    "delay": float(wave_entry), # NOTE use for betting wars!
                    "count": count,
                    "img": image if image else "",
                    "prefix": npc_name_prefix,
                    "display_name": display_name,
                    "extra_info": extra_info + desc,
                    "is_support": util.cfgtonum(dd["is_boss"]) < 2 and (dd["ignore_max_cap"]=="1" or dd["team_npc"]=="2" or dd["is_static"]=="1")
                }
            )
        
        if (not has_cash_entry) and len(DEFAULT_CASH_BY_WAVE)>=wave_idx and auto_wave_cash:
            output.append({
                "type": "info",
                "text": f"Wave cash: <span class=\"money\">{DEFAULT_CASH_BY_WAVE[wave_idx-1]}</span>"
            })

        return output
    
    def parse_waveset(file, data, abslink, name, desc, DEPTH=2):
        global waveset_cache
        if file in waveset_cache:
            util.debug(f"    -> Returning cache for {file}", "waveset", "OKCYAN")
            return waveset_cache[file]
        
        wd = defaultdict(str,data)
        output = {
            "waves": {},
            # TODO show authors, item on win and modified music entries in waveset viewer (or waveset link hover?)
            "authors": {
                "npc": wd["author_npcs"],
                "format": wd["author_format"],
                "raid": wd["author_raid"]
            },
            "item_on_win": wd["complete_item"],
            "fakemaxwaves": wd["fakemaxwaves"]
        }
        
        wave_idx = 0

        max_waves = 0
        for wave in data:
            try:
                int(wave)
            except ValueError:
                continue
            max_waves=max(int(wave),max_waves)
        assert max_waves!=0

        for wave in data:
            wave_data = data[wave]
            try:
                int(wave)
            except ValueError:
                continue
                if wave.startswith("music_") and False:
                    if (mdata := util.music_modal(wave_data)): output += mdata
                continue

            wave_npc_amt = sum([int(util.is_float(entry)) for entry in wave_data])
            if len(wave_data)==0 or wave_npc_amt == 0: continue
            wave_idx += 1

            output["waves"][wave_idx] = parse_wave(wave_idx, wave_data, bool(util.cfgtonum(wd["auto_wave_cash"])))
            embed.generate_waveset_embed(f"{abslink}_{wave_idx}", name, int(wave), max_waves, output["waves"][wave_idx])
        
        waveset_cache[file] = output
        return output
    
    def parse_waveset_list_cfg_common(cfg, filename, html_mapsets):
        map_mode = "maps" in filename # Is map specific config?
        WAVESET_LIST = cfg[list(cfg.keys())[0]] # data of cfg file
        if "Setup" in WAVESET_LIST: WAVESET_LIST = WAVESET_LIST["Setup"] # map-specific configs start with custom instead of setup, requiring an extra step to get to waveset/wave< data
        if "Setup" in WAVESET_LIST: WAVESET_LIST = WAVESET_LIST["Setup"] # zr_bossrush

        wavesetlist_html = ""
        wavesets_json = {}

        if "Waves" in WAVESET_LIST: # list of wavesets
            wavesets = WAVESET_LIST["Waves"]
            # Outline
            wavesetlist_html += "<ul>\n"
            for waveset_name in wavesets:
                link = f"{util.absolute_link(filename,waveset_name)}.json"
                wavesetlist_html += f"<li><a href=\"waveset_viewer.html?w={link}\">{waveset_name}</a></li>\n"
            wavesetlist_html += "</ul>\n"
            if map_mode: 
                n = filename.split("/")[-1].replace(".cfg","")
                html_mapsets += f"<li><a href=\"{n}.html\">{n}</a></li>"

            # Modifier outline
            if "Modifiers" in WAVESET_LIST:
                wavesetlist_html += f"<h2>Modifiers</h2>\n"
                for modifier in WAVESET_LIST["Modifiers"]:
                    data = WAVESET_LIST["Modifiers"][modifier]
                    desc = util.get_key(data["desc"]).replace("\\n","</div>\n<div>")
                    # no idea what the levels here mean
                    lvl = round(float(data["level"])*1000) # waves.sp line 1018: vote.Level = RoundFloat(kv.GetFloat("level", 1.0) * 1000.0);
                    context = {
                        "name": modifier,
                        "data_modifier": f"<div>Level: {lvl}</div>\n<div>{desc}</div>\n"
                    }
                    wavesetlist_html += util.fill_template(util.read("templates/waveset/modifier_preview.html"), context)    
            
            # Data
            for waveset_name in wavesets:
                waveset_file = wavesets[waveset_name]["file"]
                util.log(f"    {waveset_name}{" "*(35-len(waveset_name))}| {waveset_file}")
                wave_cfg = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{waveset_file}.cfg")
                
                # Waveset-specific typo fixes (or just removing lines that break the parser)
                if waveset_file == "classic_iber&expi": wave_cfg=wave_cfg.replace('			"plugin"	"110000000"',"") # overrides actual plugin name before it, which is why it has to be removed
                wave_cfg = unique_enemy_delays(wave_cfg)

                WAVESET_DATA = KeyValues1.parse(wave_cfg)["Waves"]

                if "desc" in wavesets[waveset_name]:
                    waveset_desc_key = wavesets[waveset_name]["desc"]
                    desc = util.get_key(waveset_desc_key).replace("\\n","  \n")
                    if desc == "":
                        desc = waveset_desc_key.replace("\\n","  \n") # Blame Artvin PR #895 for not translating a desc
                else:
                    desc = ""
                util.debug(f"Adding waveset {waveset_name} to {filename}","wavesets","OKCYAN")
                mn = parse_waveset(waveset_file, WAVESET_DATA, util.absolute_link(filename,waveset_name), waveset_name, desc)
                mn["name"] = waveset_name
                wavesets_json[waveset_name] = mn
        else: # Waveset itself / map_mode | Assume data being in the cfg file itself. Might only be the case for rogue/const/bettingwars
            util.log(f"{filename} - No 'Waves' key found!","FAIL")
            raise Exception
        
        if not os.path.isdir("gh-pages/wavesets"): subprocess.run(["mkdir", "gh-pages/wavesets"])
        for f_waveset, f_data in wavesets_json.items():
            util.write(f"gh-pages/wavesets/{util.absolute_link(filename,f_waveset)}.json", json.dumps(f_data,indent=2))

        context = { # startcash, wavesetlistdata
            "startcash": WAVESET_LIST["cash"],
            "wavesetlistdata": wavesetlist_html
        }
        HTML_WAVESET_LIST = util.fill_template(util.read(f"templates/waveset/{"mapset_overview" if map_mode else "waveset_list"}.html"),context)
        return HTML_WAVESET_LIST, html_mapsets

    def parse_waveset_list_cfg(filename, html_mapsets, filename_md=None):
        if (filename not in util.WAVESETS_FILESCOPE) and len(util.WAVESETS_FILESCOPE)>0:
            util.log(f"{filename} not in FILESCOPE", "OKBLUE")
            return html_mapsets
        WAVESETLIST_RAW = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{filename}")
        WAVESETLIST_DATA = KeyValues1.parse(WAVESETLIST_RAW)
        WAVESETLIST_TYPE = list(WAVESETLIST_DATA.keys())[0]

        if WAVESETLIST_TYPE not in util.WAVESETS_TYPESCOPE: # Unsupported waveset cfg (Rogue, Bunker, etc.)
            util.log(f"Unsupported waveset cfg {filename}!","WARNING")
            return html_mapsets
        
        util.log(f"Parsing waveset list cfg: {filename}")

        """
        maps/zr_bunker_old_fish.cfg - currently disabled in zr? and has missing files
        maps/zr_beastrooms.cfg - empty
        maps/zr_holdout.cfg - const ?

        maps/zr_construction.cfg - const1
        maps/zr_const2_headquarters.cfg - const2 (codename dungeon)
        
        maps/zr_bettingwars.cfg - betting: delay defines budget/describes how powerful the NPCs are

        maps/zr_integratedstrategies.cfg - rogue1
        maps/zr_deepforest.cfg - rogue2
        maps/zr_rift_between_fates.cfg - rogue3
        """

        if WAVESETLIST_TYPE in ["Setup", "Custom"]:
            HTML_WAVESETS, html_mapsets = parse_waveset_list_cfg_common(WAVESETLIST_DATA, filename, html_mapsets)
        elif WAVESETLIST_TYPE == "Betting":
            HTML_WAVESETS, md_npc, md_mapsets = parse_betting(filename, WAVESETLIST_RAW, md_mapsets)
        elif WAVESETLIST_TYPE == "Rogue":
            HTML_WAVESETS, md_npc, md_mapsets = parse_rogue(filename, WAVESETLIST_DATA, md_mapsets)
        else:
            HTML_WAVESETS = f"err key {WAVESETLIST_TYPE}"
            util.log("UNSUPPORTED CFG IN OUTPUT!", "FAIL")

        if not filename_md:
            if "maps" in filename:
                filename_md = f"gh-pages/{filename.split("/")[-1].replace(".cfg","")}.html"
            else:
                filename_md = f"gh-pages/wavesets_{filename}.html".replace("/","_")
        name = filename_md.split("/")[-1].replace(".html","")
        if "maps" not in filename: name=name.title()
        util.write(filename_md, util.fill_template(HTML_WAVESETS,{"wavesetlistname":name}))
        return html_mapsets
    
    #### ZR: Special Maps ####
    def parse_betting(name, data_raw, md_npc, md_mapsets): # zr_bettingwars
        data = KeyValues1.parse(unique_enemy_delays(data_raw))
        betting_music = util.music_modal(data["Betting"]["BetWars"]["music_background"])
        mn, md_npc = parse_wave(data["Betting"]["Waves"]["Freeplay"], md_npc, is_betting=True, force=True)

        n = name.split("/")[-1].replace(".cfg","")
        md_mapsets += f"- [{n}]({n})  \n"
        
        return f"{betting_music}\n  Higher budget means more powerful NPC group\n  {mn}", md_npc, md_mapsets
    
    #### ZR: Rogue ####
    def parse_rogue(name, data, md_npc, md_mapsets):
        data=data["Rogue"]
        
        # Starting data (cash, artifacts, rogue 1/2/3)
        #tooltip_data = "Drop chance: All non-collected (and sometimes non-blacklisted) droppable items get added <chance> times to a list, from which an item gets randomly chosen."
        ## {tooltip_data}  \n
        ## -> [Floors](#Floors)  \n
        music_text = ""
        for entry, val in data.items():
            if "music" in entry:
                music_text += util.music_modal(val)
        md_stages = ""
        md = ""
        for artifact in data["Setup"]["Starting"].keys():
            md += rogue_item_modal(artifact)

        # Curses
        md += "# Curses\n"
        for curse in data["Rogue"]["Curses"].keys():
            md += rogue_item_modal(curse)

        # All Artifacts
        md += "# Artifacts\n"
        for artifact in data["Rogue"]["Artifacts"]:
            # TODO try to replace this with defaultdict again at some point
            obj = data["Rogue"]["Artifacts"][artifact]
            if "hidden" in obj:
                if obj["hidden"]=="1": continue
            md += rogue_item_modal(artifact, obj)
        
        # Floors
        md += "# Floors\n"
        for idx, (floor_name, floor_data) in enumerate(data["Rogue"]["Floors"].items()):
            rooms = floor_data["rooms"]
            md += f"## {idx+1}. {floor_name}\n{rooms} room{"s"*int(int(rooms)>1)}  \n"
            for entry, val in floor_data.items():
                if "music" in entry:
                    md += f"{entry.split("_")[0].title()}: {util.music_modal(val)}"
            
            md_stages += f"    {idx+1}. {floor_name}  \n"
            for sname, sdata in floor_data["Stages"].items():
                sd = defaultdict(str, sdata)
                util.log(f"    {sname}{" "*(35-len(sname))}| {sd["wave"] if "wave" in sdata else "-"}")
                key_text = f"Only with{"out"*int(sd["keyinverse"]=="1")} key: {sd["key"]}  \n" if "key" in sdata else ""
                md += f"### {sname}\n{key_text}{"_Encounter_  \n" if sd["camera"].startswith("camera_encounter") else ""}"
                if "wave" in sdata:
                    wave_cfg = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{sdata["wave"]}.cfg")
                    wave_cfg = unique_enemy_delays(wave_cfg)
                    WAVESET_DATA = KeyValues1.parse(wave_cfg)["Waves"]
                    md, md_npc = parse_waveset(sdata["wave"], WAVESET_DATA, md, md_npc, DEPTH=4)
                md_stages +=  f"    - [{sname}](#{util.to_section_link(sname).replace("!","-1")})  \n"

        md = f"# Rogue {int(data["Rogue"]["roguestyle"])+1}\n\n- [Curses](#Curses)  \n- [Artifacts](#Artifacts)  \n- [Floors](#Floors)  \n{md_stages}\nStarting cash: ${data["Setup"]["cash"]}{music_text}  \n\n" + md

        # list in home.md, sidebar.md
        n = name.split("/")[-1].replace(".cfg","")
        rogue_num = f" - Rogue {int(data["Rogue"]["roguestyle"])+1}"
        md_mapsets += f"- [{n+rogue_num}]({n})  \n"

        return md, md_npc, md_mapsets

    def rogue_item_modal(name, obj={}):
        shop_cost = f"$$ cost \\space △ {obj["shopcost"]} $$\n" if "shopcost" in obj else ""
        dropchance = f"$$ dropchance \\space {obj["dropchance"]} $$\n" if "dropchance" in obj else ""
        modal = f"$$ \\textbf{{ {util.get_key(name).replace("&","\\&")} }} $$\n{shop_cost}{dropchance}$$\n{util.as_latex(util.get_key(f"{name} Desc"))}\n$$"
        return modal + "  \n"

    PATH_NPC = "./TF2-Zombie-Riot/addons/sourcemod/scripting/zombie_riot/npc/"

    if not os.path.isdir("gh-pages/embed"): subprocess.run(["mkdir", "gh-pages/embed"])
    if not os.path.isdir("gh-pages/waveset_embeds"): subprocess.run(["mkdir", "gh-pages/waveset_embeds"])
    if not os.path.isdir("repo_img"): subprocess.run(["mkdir", "repo_img"])

    util.log("Fetching base data...")
    NPCS_BY_FILENAME, NPCS_BY_CATEGORY = parse_all_npcs()
    DEFAULT_CASH_BY_WAVE = parse_default_cash()
    util.write("npcs_by_category.json", json.dumps(NPCS_BY_CATEGORY,indent=2))

    cfg_files = {
        "classic.cfg": "gh-pages/survival.html",
        "fastmode.cfg": "gh-pages/raidrush.html",
    }
    for file in os.listdir("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/maps/"):
        if ".cfg" in file:
            cfg_files[f"maps/{file}"] = None

    HTML_SPECIALMAPS = ""
    for f,n in cfg_files.items():
        HTML_SPECIALMAPS = parse_waveset_list_cfg(f, HTML_SPECIALMAPS, filename_md=n)

    # Get current commit SHA for TF2-Zombie-Riot
    COMMIT_SHA = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd="TF2-Zombie-Riot").strip().decode("utf-8")
    COMMIT_SHA_SHORT = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd="TF2-Zombie-Riot").strip().decode("utf-8")

    context = {
        "wavesetlistdata": HTML_SPECIALMAPS # list of mapset_overview templates
    }    
    util.write("gh-pages/special.html", util.fill_template(util.read("templates/waveset/mapset_list.html"), context))

    context = {
        "parse_run": f"\n<sub>Code parsed at {util.datetime.datetime.now().strftime('%H:%M:%S %d.%m.%Y')} H:M:S D.M.Y {time.tzname[time.daylight]}</sub><br><sub>Source repository commit <a href=\"https://github.com/artvin01/TF2-Zombie-Riot/commit/{COMMIT_SHA}\">artvin01/TF2-Zombie-Riot@{COMMIT_SHA_SHORT}</a></sub>",
    }
    util.write("gh-pages/index.html", util.fill_template(util.read("templates/index.html"),context))
    return generated_files