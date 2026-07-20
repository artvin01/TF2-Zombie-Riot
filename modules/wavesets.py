# Parse all NPCs & Wavesets (Normal & Custom, wavesets like Construction are yet to be supported.)
import util
import os
import subprocess
import pathlib
import json
import time
import modules.shared
import vdf
from collections import defaultdict
from datetime import datetime
from typing import Any

"""
TODO
[ ] Complete const2 support
[ ] Include main music parts somehow
"""

# General ================================
PROPERTY_MAPPINGS = {
    "is_boss": {
        "0": "", # used in rogue??? why..
        "1": "Boss",
        "2": "RaidWithPrepare",
        "3": "RaidNoPrepare",
        "4": "" # unknown, used in bossrush
    },
    "is_outlined": "Outline",
    "force_scaling": "ForceScaling",
    "is_health_scaling": "HealthScaling",
    "is_immune_to_nuke": "" # deprecated => hidden
}

MULTIPLIER_MAPPINGS = {
    "extra_melee_res": "☛",
    "extra_ranged_res": "➶",
    "extra_speed": "↗",
    "extra_damage": "☖",
    "extra_size": "⤡",
}

waveset_cache: dict[str,dict[str,Any]] = {}
def parse_all_npcs() -> tuple[dict[str, modules.shared.TypeNPC], dict[str, list[modules.shared.TypeNPC]]]:
    npc_by_file: dict[str,modules.shared.TypeNPC] = {}
    npc_by_category: dict[str,list[modules.shared.TypeNPC]] = {}
    for file in pathlib.Path(PATH_NPC).glob('**/*'):
        if os.path.isfile(file.absolute()):
            npc_obj = modules.shared.NPC(str(file.absolute()))
            if not npc_obj.HIDDEN:
                plugin_name = npc_obj.plugin
                if type(plugin_name) is list:
                    for i,pn in enumerate(plugin_name):
                        dummy = modules.shared.NPC_Dummy(npc_obj)
                        if npc_obj.filetype == "shared":
                            dummy.health = npc_obj.health[min(len(npc_obj.health)-1,i)]
                        else:
                            dummy.health = npc_obj.health
                        dummy.category = npc_obj.category[min(len(npc_obj.category)-1,i)]
                        dummy.plugin = npc_obj.plugin[min(len(npc_obj.plugin)-1,i)]
                        dummy.flags = npc_obj.flags[min(len(npc_obj.flags)-1,i)]
                        npc_by_file[pn] = dummy
                        if dummy.category not in npc_by_category:
                            npc_by_category[dummy.category] = []
                        npc_by_category[dummy.category].append(dummy)
                else:
                    npc_by_file[plugin_name] = npc_obj
                    if npc_obj.category not in npc_by_category:
                        npc_by_category[npc_obj.category]=[]
                    npc_by_category[npc_obj.category].append(npc_obj)

    if "npcs" in util.DEBUG:
        util.write("npc_data.json",json.dumps(npc_by_file,indent=2))

    return npc_by_file, npc_by_category

def parse_default_cash():
    return util.normalize_whitespace(util.read("TF2-Zombie-Riot/addons/sourcemod/scripting/zombie_riot/zr_core.sp").split("public const int DefaultWaveCash[] =\n{\n")[1].split("\n};")[0]).split(", ")

def parse_default_mission_client(): # Default for 'character_hired_by' entry
    return util.read("TF2-Zombie-Riot/addons/sourcemod/scripting/zombie_riot/zr_core.sp").split('#define DEFAULT_MISSION_CLIENT "')[1].split('"')[0]

def unique_enemy_delays(w: str) -> str:
    # Make each wave delay unique as not to lose out on info (for example if 2 enemies have same wave delay)
    # https://stackoverflow.com/questions/41941116/replace-each-occurrence-of-sub-strings-in-the-string-with-randomly-generated-val
    space = "		"

    def bl(n_w,n_dstr):
        n_dstr_ct = n_w.count(n_dstr)
        n_w = n_w.replace("{","{{").replace("}","}}") # double curly brackets get ignored by .format
        n_w = n_w.replace(f'{space}"{n_dstr}"', space+'"{}"')
        return n_w.format(*(" "*i + n_dstr for i in range(n_dstr_ct)))

    for d in range(0,4):
        if f"{d}." in w:
            for d2 in range(0,10):
                dstr = f"{d}.{d2}"
                if f"{d}.{d2}":
                    w = bl(w,dstr)
                    for d3 in range(0,10):
                        dstr = f"{d}.{d2}{d3}"
                        if dstr: w = bl(w,dstr)
    
    return w

def get_npc(plugin: str) -> dict[str, str]:
    npc_data = NPCS_BY_FILENAME[plugin]
    assert type(npc_data.flags) is list
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

def parse_wave(wave_idx: int, wave_data: dict[str, Any], auto_wave_cash: bool, return_obtainables=False):
    output:list[dict[str,Any]] = []
    output_hashes: dict[str,int] = {}
    has_cash_entry = False
    obtainables = []

    for wave_entry, wave_entry_data in wave_data.items():
        try:
            float(wave_entry)
        except ValueError:
            if wave_entry.startswith("music_"):
                if (modal := util.music_modal(wave_entry_data)):
                    MUSIC_BY_TITLE[modal["musictitle"]] = modal
                    output.append(modal)

            if wave_entry == "xp":
                output.append({
                    "type": "info",
                    "text": f"Wave XP: {int(wave_entry_data)*5}" #
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
                    "text": f"Setup time: {util.as_duration(int(wave_entry_data))}"
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
        Int health => Hidden
        Bool is_boss => Flag //if a npc has this, they will get outlined, bonus damage, and their health scales. (1: boss 2: raid w/prepare :3 raid w/o prepare 4: ?)
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
        String custom_name => Builtin (replaces NPC name)
        (
        String data => Builtin (variations of the same NPC)
        String spawn ?
        )
        """

        # NOTE count is no longer bold when not scaled!!
        count = "1" if wave_entry_data["count"] == "0" else wave_entry_data["count"]

        if wave_entry_data["plugin"] in NPCS_BY_FILENAME:
            npc_data = NPCS_BY_FILENAME[wave_entry_data["plugin"]]
            if (npc_data.category=="Type_Hidden") and (wave_entry_data["plugin"] not in modules.shared.NPC_WHITELIST):
                continue
        else:
            # force argument would be used here, but the code is no longer handling None values properly
            util.log(f"Plugin name {wave_entry_data["plugin"]} missing!","FAIL")
            raise FileNotFoundError

        try:
            npc_name = npc_data.name
        except AttributeError:
            npc_name = wave_entry_data["plugin"]
        npc_name_raw = npc_name

        if "custom_name" in wave_entry_data:
            npc_name = wave_entry_data["custom_name"]

        if npc_data.obtain_item:
            obtainables.append({
                "item": npc_data.obtain_item,
                "npc_name": npc_name,
            })

        dd = defaultdict(str, wave_entry_data)
        npc_name_prefix = ""
        # Health data
        """
        bool carrier = data[0] == 'R';
        bool elite = !carrier && data[0];
        """
        extra_info:str = ""
        if "health" in wave_entry_data:
            extra_info += f" {util.format_num(wave_entry_data["health"])}HP"
        elif npc_data:
            if type(npc_data.health) is dict:
                if len(dd["data"])>0 and npc_data.has_prefix_logic:
                    """
                    prefix logic:
                        bool carrier = data[0] == 'R';
                        bool elite = !carrier && data[0];

                    usually accompanied with data like:
                        "Regressed"
                        "Elite"
                    """
                    data_key = wave_entry_data["data"]

                    # prefixes (logic carried over from zr code)
                    carrier = data_key[0] == "R"
                    elite = (not carrier) and data_key[0] # If first char isn't R but data exists

                    data_key = "carrier" if carrier else ("elite" if elite else "default" if (npc_name_prefix:="!c") else None)
                    if data_key is None:
                        util.log("NPC data_key is somehow None!","FAIL")
                        raise Exception

                    if data_key not in npc_data.health and "any" in npc_data.health:
                        data_key = "any"
                    elif data_key not in npc_data.health:
                        data_key = "default"

                    npc_name_prefix += wave_entry_data["data"].capitalize()
                    util.debug(f"Parsing HP Value {npc_data.health} DATA value {wave_entry_data["data"]} CHOSEN value {data_key}", "npcs", "OKCYAN")
                    h = f" {npc_data.health[data_key.lower()]}"
                else:
                    h = npc_data.health["default"]

                extra_info += f" {util.format_num(h)}HP"
            else:
                extra_info += f" {npc_data.health}"
        else:
            extra_info += " ?HP"

        # (by property in waveset) Auto NPC flags (SetupFlags logic in waves.sp)
        """
        Miniboss
        if(data.Is_Boss || data.Is_Outlined)
            flags |= MVM_CLASS_FLAG_MINIBOSS;

        Alwayscrit
        if(data.ExtraMeleeRes < 1.0 ||
        data.ExtraRangedRes < 1.0 ||
        data.ExtraSpeed > 1.0 ||
        data.ExtraDamage > 1.0 ||
        data.ExtraThinkSpeed > 1.0 ||
        data.Is_Boss > 1)
            flags |= MVM_CLASS_FLAG_ALWAYSCRIT;
        """
        npc_css_class = ""
        npc_extra_flags: list[str] = []

        cases = {
            "MVM_CLASS_FLAG_SUPPORT": util.cfgtoint(dd["is_boss"]) < 2 and (dd["ignore_max_cap"]=="1" or dd["team_npc"]=="2" or dd["is_static"]=="1"),
            "MVM_CLASS_FLAG_MINIBOSS": (util.cfgtoint(dd["is_boss"]) or util.cfgtoint(dd["is_outlined"])),
            "MVM_CLASS_FLAG_ALWAYSCRIT": util.cfgtofloat(dd["extra_melee_res"],1.0)<1.0 or \
                        util.cfgtofloat(dd["extra_ranged_res"],1.0)<1.0 or \
                        util.cfgtofloat(dd["extra_speed"],1.0)>1.0 or \
                        util.cfgtofloat(dd["extra_damage"],1.0)>1.0 or \
                        util.cfgtofloat(dd["extra_thinkspeed"],1.0)>1.0 or \
                        util.cfgtoint(dd["is_boss"])>1
        }
        if npc_data:
            for flag,case_ in cases.items():
                if case_ and (flag not in npc_data.flags):
                    extra_info += f" {modules.shared.FLAG_MAPPINGS[flag]}"
                    npc_css_class += f" {modules.shared.FLAG_CSS[flag]}"
                    npc_extra_flags.append(flag)
        else:
            for flag,case_ in cases.items():
                if case_:
                    extra_info += f" {modules.shared.FLAG_MAPPINGS[flag]}"
                    npc_css_class += f" {modules.shared.FLAG_CSS[flag]}"
                    npc_extra_flags.append(flag)

        # (in code) Predefined NPC flags (plugin_name.sp data.Flags=<x>)
        desc = ""
        if npc_data:
            for flag in npc_data.flags:
                if flag != "0" and flag != "-1":
                    extra_info += f" {modules.shared.FLAG_MAPPINGS[flag]}"
                    npc_css_class += f" {modules.shared.FLAG_CSS[flag]}"
                    npc_extra_flags.append(flag)

            # Get icon
            image = modules.shared.get_npc_icon(npc_data.icon)

            if npc_data.category != "Type_Hidden":
                desc = f"<div class=\"flex_break\"></div>\n{util.divfornewline(get_npc(wave_entry_data["plugin"])["description"])}"
        else:
            # temporarily an actual missing image
            image = "missing.png" # npc not found at all. this only happens when parse_wave has force=true

        for property_, val in PROPERTY_MAPPINGS.items():
            if property_ in wave_entry_data:
                if type(val) is dict:
                    extra_info += f" {val[wave_entry_data[property_]]}"
                else:
                    if wave_entry_data[property_] == "1":
                        extra_info += f" {val}"

        for multiplier, char in MULTIPLIER_MAPPINGS.items():
            if multiplier in wave_entry_data:
                percent = float(wave_entry_data[multiplier])*100

                percent_text = f"{percent:.2f}"
                if float(percent_text).is_integer():
                    percent_text = int(percent)

                extra_info += f" {char} {percent_text}％"

        # Turn NPC music entries into simple text.
        music = ""
        for entry in npc_data.music_entries:
            MUSIC_BY_TITLE[entry["musictitle"]] = entry
            music += util.musicmodal_to_html(entry)

        # Add npc to wave data output for waves.js to be parsed
        npc_output = {
            "type": "npc",
            "img": image if image else "",
            "prefix": npc_name_prefix,
            "display_name": npc_name,
            "true_name": npc_name_raw, # Unused for now, might be used in inspect mode.
            "plugin_name": wave_entry_data["plugin"], # Unused for now, might be used in inspect mode.
            "extra_info": extra_info + desc + music,
            # waves.sp line 4165 if(data.Is_Boss < 2 && (support || data.ignore_max_cap || data.Is_Static || data.Team == TFTeam_Red))
            "css_class": npc_css_class,
        }
        npc_hash = util.id_from_str(json.dumps(npc_output)) # same NPC data will output same hash
        npc_output["count"] = count
        npc_output["delay"] = float(wave_entry) # Budget in betting wars
        if npc_hash not in output_hashes:
            output.append(
                npc_output
            )
            output_hashes[npc_hash] = len(output)-1
        else:
            output[output_hashes[npc_hash]]["count"] = str(int(output[output_hashes[npc_hash]]["count"]) + int(npc_output["count"]))


    if (not has_cash_entry) and len(DEFAULT_CASH_BY_WAVE)>=wave_idx and auto_wave_cash:
        output.append({
            "type": "info",
            "text": f"Wave cash: <span class=\"money\">{DEFAULT_CASH_BY_WAVE[wave_idx-1]}</span>"
        })

    if return_obtainables:
        return output,obtainables
    else:
        return output

def parse_waveset(file: str, data: dict[str, Any], abslink: str, name: str, desc: str) -> dict[str, Any]:
    global waveset_cache
    if file in waveset_cache:
        util.debug(f"    -> Returning cache for {file}", "wavesets", "OKCYAN")
        return waveset_cache[file]

    wd = defaultdict(str,data)
    output: dict[str,Any] = {
        "waves": {},
        "music": {}, # base waveset music, not the per wave one
        "authors": {
            "npc": wd["author_npcs"],
            "format": wd["author_format"],
            "raid": wd["author_raid"]
        },
        "desc": desc,
        "item_on_win": wd["complete_item"],
        "fakemaxwaves": wd["fakemaxwaves"],
        "character_hired_by": wd["character_hired_by"] or DEFAULT_MISSION_CLIENT
    }

    if wd["complete_item"]:
        COMPLETE_ITEM_MAP[wd["complete_item"]] = {
            "name": util.abslink_to_display(abslink,name),
            "file": f"{abslink}.json"
        }

    wave_idx = 0

    max_waves = 0 # Unused (except for assertion)
    max_waves_idx = 0
    for wave, wave_data in data.items():
        try:
            int(wave)
        except ValueError:
            continue
        max_waves=max(int(wave),max_waves)
        if len(wave_data)==0 or sum([int(util.is_float(entry)) for entry in wave_data]) == 0: # second condition checks for npc amount
            continue
        max_waves_idx += 1
    assert max_waves!=0

    for wave, wave_data in data.items():
        try:
            int(wave)
        except ValueError:
            if wave.startswith("music_"):
                if (modal := util.music_modal(wave_data)):
                    MUSIC_BY_TITLE[modal["musictitle"]] = modal
                    output["music"][wave]= modal
            continue

        if len(wave_data)==0 or sum([int(util.is_float(entry)) for entry in wave_data]) == 0: # second condition checks for npc amount
            continue
        wave_idx += 1
        output["waves"][wave_idx], obtainables = parse_wave(wave_idx, wave_data, bool(util.cfgtoint(wd["auto_wave_cash"])), return_obtainables=True)
        if not (abslink.startswith("zr_bossrush") or abslink.startswith("zr_summercamp")): # TODO does bossrush give items for bosses?
            for obt in obtainables:
                """
                TODO: 
                - Blitzkrieg's Army(donnerkrieg has entry and blitzkrieg doesnt)
                """
                if obt["item"] not in COMPLETE_ITEM_MAP:
                    COMPLETE_ITEM_MAP[obt["item"]] = {
                        "name": f"{util.abslink_to_display(abslink,name)}|{obt["npc_name"]}",
                        "file": f"{abslink}.json&wv={wave_idx}"
                    }
                else:
                    util.log(f"Duplicate {obt["item"]} in w:{abslink}|wv:{wave_idx}|npc:{obt["npc_name"]}", "WARNING")

    waveset_cache[file] = output
    return output


# Core ================================
def parse_waveset_list_cfg(filename: str, html_mapsets: str, html_otherset: dict[str, str], filename_md: str | None = None) -> tuple[str, dict[str, str]]:
    if (filename not in util.WAVESETS_FILESCOPE) and len(util.WAVESETS_FILESCOPE)>0:
        util.log(f"{filename} not in FILESCOPE", "OKBLUE")
        return html_mapsets, html_otherset
    WAVESETLIST_RAW = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{filename}")
    WAVESETLIST_DATA: dict[str,Any] = vdf.loads(WAVESETLIST_RAW) # type:ignore[w]
    WAVESETLIST_TYPE = list(WAVESETLIST_DATA.keys())[0]

    if (WAVESETLIST_TYPE not in util.WAVESETS_TYPESCOPE) or "maps/zr_holdout.cfg" == filename: # Unsupported waveset cfg (Bunker, etc.)
        util.log(f"Unsupported waveset cfg {filename}!","WARNING")
        return html_mapsets, html_otherset

    util.log(f"Parsing waveset list cfg: {filename}")

    """
    maps/zr_bunker_old_fish.cfg - currently disabled in zr? and has missing files
    maps/zr_beastrooms.cfg - empty
    maps/zr_holdout.cfg - scrapped

    maps/zr_construction.cfg - const1
    maps/zr_const2_headquarters.cfg - const2 (codename dungeon)

    maps/zr_bettingwars.cfg - betting: delay defines budget/describes how powerful the NPCs are

    maps/zr_integratedstrategies.cfg - rogue1
    maps/zr_deepforest.cfg - rogue2
    maps/zr_rift_between_fates.cfg - rogue3
    """

    if WAVESETLIST_TYPE in ["Setup", "Custom"]:
        html_waveset, html_mapsets = parse_common(WAVESETLIST_DATA, filename, html_mapsets)
    elif WAVESETLIST_TYPE == "Betting":
        html_waveset, html_mapsets = parse_betting(filename, WAVESETLIST_RAW, html_mapsets)
    else:
        if WAVESETLIST_TYPE not in html_otherset:
            html_otherset[WAVESETLIST_TYPE] = ""
        if WAVESETLIST_TYPE == "Rogue":
            html_waveset, html_otherset[WAVESETLIST_TYPE] = parse_rogue(filename, WAVESETLIST_DATA, html_otherset[WAVESETLIST_TYPE])
        elif WAVESETLIST_TYPE == "Construction":
            html_waveset, html_otherset[WAVESETLIST_TYPE] = parse_const(filename, WAVESETLIST_DATA, html_otherset[WAVESETLIST_TYPE])
        else:
            util.log(f"UNSUPPORTED WAVESETLIST_TYPE: {WAVESETLIST_TYPE}", "FAIL")
            exit()

    if not filename_md:
        if "maps" in filename:
            filename_md = f"gh-pages/{filename.split("/")[-1].replace(".cfg","")}.html"
        else:
            filename_md = f"gh-pages/wavesets_{filename}.html".replace("/","_")
    name = filename_md.split("/")[-1].replace(".html","")
    if "maps" not in filename:
        name=name.title()
    util.write(filename_md, util.fill_template(html_waveset,{"wavesetlistname":name}))
    return html_mapsets, html_otherset

# Parsing code for each waveset type ================================
### Common ###
def parse_common(cfg: dict[str, Any], filename: str, html_mapsets: str):
    map_mode = "maps" in filename # Is map specific config?
    waveset_list: dict[str,Any] = cfg[list(cfg.keys())[0]] # data of cfg file
    [(waveset_list := waveset_list["Setup"]) for _ in range(2) if "Setup" in waveset_list] # map-specific configs start with custom instead of setup, requiring an extra step to get to waveset/wave< data

    wavesetlist_html = ""
    wavesets_json: dict[str,dict[str,Any]] = {}

    if "Waves" in waveset_list: # list of wavesets
        wavesets = waveset_list["Waves"]
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
        if "Modifiers" in waveset_list:
            wavesetlist_html += "<h2>Modifiers</h2>\n"
            for modifier in waveset_list["Modifiers"]:
                data = waveset_list["Modifiers"][modifier]
                desc = util.get_key(data["desc"]).replace("\\n","\n")
                # no idea what the levels here mean
                lvl = round(float(data["level"])*1000) # waves.sp line 1018: vote.Level = RoundFloat(kv.GetFloat("level", 1.0) * 1000.0);
                context = {
                    "name": modifier,
                    "data_modifier": f"<div>Level: {lvl}</div>\n{util.divfornewline(desc)}\n"
                }
                wavesetlist_html += util.fill_template(util.read("templates/waveset/modifier_preview.html"), context)

        # Data
        for waveset_name in wavesets:
            waveset_file = wavesets[waveset_name]["file"]
            util.log(f"    {waveset_name}{" "*(35-len(waveset_name))}| {waveset_file}")
            wave_cfg = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{waveset_file}.cfg")

            # Waveset-specific typo fixes (or just removing lines that break the parser)
            wave_cfg = unique_enemy_delays(wave_cfg)

            WAVESET_DATA: dict[str,Any] = vdf.loads(wave_cfg)["Waves"] # type: ignore[w]

            if "desc" in wavesets[waveset_name]:
                waveset_desc_key = wavesets[waveset_name]["desc"]
                desc = util.get_key(waveset_desc_key).replace("\\n","  \n")
                if desc == "":
                    desc = waveset_desc_key.replace("\\n","  \n") # Blame Artvin PR #895 for not translating a desc
            else:
                desc = ""
            util.debug(f"Adding waveset {waveset_name} to {filename}","wavesets","OKCYAN")
            mn = parse_waveset(waveset_file, WAVESET_DATA, util.absolute_link(filename,waveset_name), waveset_name, desc) # type: ignore[w] (dict[str,Any] is passed -> argument type partially unknown warning)
            mn["name"] = waveset_name
            wavesets_json[waveset_name] = mn
    else:
        util.log(f"{filename} - No 'Waves' key found!","FAIL")
        raise Exception

    for f_waveset, f_data in wavesets_json.items():
        util.write(f"gh-pages/wavesets/{util.absolute_link(filename,f_waveset)}.json", json.dumps(f_data,indent=2))

    context = { # startcash, wavesetlistdata
        "startcash": waveset_list["cash"],
        "wavesetlistdata": wavesetlist_html
    }
    HTML_WAVESET_LIST = util.fill_template(util.read(f"templates/waveset/{"mapset_overview" if map_mode else "waveset_list"}.html"),context)
    return HTML_WAVESET_LIST, html_mapsets


#### ZR: Special Maps ####
def parse_betting(name: str, data_raw: str, html_mapsets:str) -> tuple[str, str]: # zr_bettingwars
    data: dict[str,Any] = vdf.loads(unique_enemy_delays(data_raw)) # type: ignore[w]

    # Generate a table out of data
    bettingdata = "<table>\n<tr>\n<th>Budget</th>\n<th>Count</th>\n<th>NPC</th>\n</tr>\n"
    output = parse_wave(0, data["Betting"]["Waves"]["Freeplay"], False)
    for entry in output:
        if entry["type"] == "npc":
            context = {
                "npc_name": f"{util.html_img(entry["img"])} {entry["prefix"]} {entry["display_name"]}",
                "plugin_name": "",
                "flags": "",
                "desc": entry["extra_info"],
                "li": "div"
            }
            npcdata = util.fill_template(util.read("templates/npc/npc_preview.html"),context)
            bettingdata += f"<tr>\n<td>{entry["delay"]}</td>\n<td>{entry["count"]}</td>\n<td>{npcdata}</td>\n</tr>\n"
    bettingdata += "</table>"

    n = name.split("/")[-1].replace(".cfg","")
    util.write(f"gh-pages/wavesets/{n}.json",json.dumps(output,indent=2))
    html_mapsets += f"<li><a href=\"{n}.html\">{n}</a></li>"

    mm = util.music_modal(data["Betting"]["BetWars"]["music_background"])
    assert mm is not None
    MUSIC_BY_TITLE[mm["musictitle"]]=mm
    betting_music = util.musicmodal_to_html(mm)
    desc = '<div style="margin-bottom: 1em;margin-top:1em;">Higher budget means more powerful NPC group</div>\n'
    context = {
        "wavesetlistdata": betting_music + desc + bettingdata,
    }
    return util.fill_template(util.read("templates/betting/bettingdata.html"),context), html_mapsets


#### ZR: Rogue ####
def parse_rogue(name: str, data: dict[str, Any], html_mapsets: str) -> tuple[str, str]:
    data=data["Rogue"]
    wd = defaultdict(str,data)
    """
    if(RogueTheme == BlueParadox || RogueTheme == ReilaRift)
	    s_MissionClient = "{black}Izan";
    # Rogue 1 overview
    - Artifacts
    - Curses
    - Floors
        - i. one
            a -> encounter, no enemies. preparsed tooltip
            b -> link to rogue/waveset viewer with floor_encounter.json as data
            c -> encounter, absolutely no info. just text
        - ii. two
            d
            e
            f

    """
    info_html: str = ""

    info_html += "<h2>Starting artifacts</h2>\n"
    for artifact in data["Setup"]["Starting"].keys():
        info_html += rogue_item_modal(artifact)

    # All Artifacts
    rogue_num = int(data["Rogue"]["roguestyle"])+1
    info_html += "<h2>Artifacts</h2>\n"
    for artifact, a_data in data["Rogue"]["Artifacts"].items():
        if defaultdict(str, a_data)["hidden"]=="1":
            continue
        info_html += rogue_item_modal(artifact,a_data)
        ARTIFACTS.append(artifact_json(artifact, a_data, f"Rogue {rogue_num}"))

    # Curses
    info_html += "<h2>Curses</h2>\n"
    for curse in data["Rogue"]["Curses"].keys():
        info_html += rogue_item_modal(curse)

    # Floors
    info_html += "<h2>Floors</h2>\n"
    for idx, (floor_name, floor_data) in enumerate(data["Rogue"]["Floors"].items()):
        rooms = floor_data["rooms"]
        dd = defaultdict(str, floor_data)
        key_text = f"<div>Only with{"out"*int(dd["keyinverse"]=="1")} key: {dd["key"]}</div>\n" if "key" in floor_data else ""
        info_html += f"<h3>{idx+1}. {floor_name}</h3>\n{key_text}<div>{rooms} room{"s"*int(int(rooms)>1)}</div>\n"

        for entry, val in floor_data.items():
            if "music" in entry:
                modal = util.music_modal(val)
                assert modal is not None
                MUSIC_BY_TITLE[modal["musictitle"]] = modal
                info_html += f"{entry.split("_")[0].title()}: {util.musicmodal_to_html(modal)}"

        info_html += "<ul>\n"
        for sname, sdata in floor_data["Stages"].items():
            info_html = parse_rogue_stage(info_html,sname,sdata,name,floor_name,rogue_num)
        info_html += "</ul>\n<h4>Final</h4>\n<ul>\n"
        for sname, sdata in floor_data["Final"].items():
            info_html = parse_rogue_stage(info_html,sname,sdata,name,floor_name,rogue_num)
        info_html += "</ul>\n"

    # List in rogue.html
    n = name.split("/")[-1].replace(".cfg","")
    html_mapsets += f"<li><a href=\"{n}.html\">{n} - Rogue {rogue_num}</a></li>"


    context = { # startcash, wavesetlistdata
        "startcash": wd["Setup"]["cash"],
        "wavesetlistname": f"Rogue {rogue_num}",
        "wavesetlistdata": info_html,
        "character_hired_by": f"{util.apply_morecolors(DEFAULT_MISSION_CLIENT) if rogue_num == 1 else util.apply_morecolors("{black}Izan")}"
    }
    HTML_WAVESET_LIST = util.fill_template(util.read("templates/rogue/roguedata.html"),context)
    # HTML_WAVESET_LIST -> what will be linked to on the ZR: rogue page
    # html_mapsets ->
    return HTML_WAVESET_LIST, html_mapsets

def rogue_item_modal(name: str, obj: dict[str, str] | str | None = None):
    desc = util.divfornewline(util.apply_morecolors(util.get_key(f"{name} Desc")))
    if type(obj) is str: # keyonwin in const
        desc += f"\n<div>{obj}</div>\n"
    elif obj is None:
        obj = {}
    context = {
        "shopcost": f"△ {obj["shopcost"]}" if "shopcost" in obj else "",
        "dropchance": f"dropchance {obj["dropchance"]}" if "dropchance" in obj else "",
        "name": util.get_key(name),
        "desc": desc
    }
    return util.fill_template(util.read("templates/rogue/rogue_item.html"),context)

def artifact_json(name: str, obj: dict[str,str], a_from: str):
    return obj | {
        "name": util.get_key(name), 
        "description": util.get_key(f"{name} Desc"), 
        "from": a_from, 
        "source": {
            "name": util.get_key_src(name),
            "description": util.get_key_src(f"{name} Desc")
        },
        "id": util.id_from_str(name+a_from)
    }

def parse_rogue_stage(info_html: str, snameraw: str, sdata: dict[str, Any], name: str, floor_name: str, rogue_num: str) -> str:
    sdesc=util.get_key(snameraw + " Desc",empty_on_fail=True,silent=True)
    if len(sdesc)>0:
        sdesc=f"<div>{sdesc}</div>"
    sname=util.get_key(snameraw)
    sd = defaultdict(str, sdata)
    util.log(f"    {sname}{" "*(35-len(sname))}| {sd["wave"] if "wave" in sdata else "-"}")
    key_text = f"<div>Only with{"out"*int(sd["keyinverse"]=="1")} key: {sd["key"]}</div>\n" if "key" in sdata else ""
    if "wave" in sdata:
        # waveset viewer link
        wave_cfg = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{sdata["wave"]}.cfg")
        wave_cfg = unique_enemy_delays(wave_cfg)
        WAVESET_DATA: dict[str,Any] = vdf.loads(wave_cfg)["Waves"] # type: ignore[w]
        absl = util.absolute_link(name,floor_name+snameraw)
        fullname = f"Rogue {rogue_num} - {floor_name} - {sname}"
        output = parse_waveset(sdata["wave"], WAVESET_DATA, absl, fullname, "") # type: ignore[w]
        output["name"]=fullname
        util.write(f"gh-pages/wavesets/{absl}.json",json.dumps(output,indent=2))
        context = {
            "name": f'<a href="waveset_viewer.html?w={absl}.json">{sname}</a>',
            "desc": f'{key_text}\n{sdesc}'
        }
    else:
        # tool tip with info
        context = {
            "name": sname,
            "desc": f'{key_text}\n{sdesc}'
        }

    if len(context["desc"])>1:
        info_html += util.fill_template(util.read("templates/rogue/rogue_encounter.html"),context)
    else:
        info_html += util.fill_template(util.read("templates/rogue/rogue_encounter_nodesc.html"),context)

    return info_html

### ZR: Construction ###
def parse_const(name: str, data: dict[str, Any], html_mapsets: str) -> tuple[str, str]:
    data=data["Construction"]
    if "dungeon" in data["Setup"]: # Const 2
        return parse_const2(name,data,html_mapsets)
    elif "construction" in data["Setup"]: # Const 1
        return parse_const1(name,data,html_mapsets)
    raise NotImplementedError

def parse_const_stage(info_html: str, cfgfile: str, keyonwin: str, attacknum: str, constnum: int) -> str:
    util.log(f"    Attack {attacknum}{" "*(35-len(f"Attack {attacknum}"))}| {cfgfile}")

    key_text = f"<div>Key on win: {keyonwin}</div>\n" if keyonwin!="" else ""

    # waveset viewer link
    wave_cfg = util.read(f"./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/{cfgfile}.cfg")
    wave_cfg = unique_enemy_delays(wave_cfg)
    WAVESET_DATA: dict[str,Any] = vdf.loads(wave_cfg)["Waves"] # type: ignore[w]
    absl = util.absolute_link(f"const{constnum}",attacknum+cfgfile)
    fullname = f"Construction {constnum} - Attack {cfgfile.replace("construction/","").replace("construction_rift/","")}" # first part of cfgfile name is attack num itself
    output = parse_waveset(cfgfile, WAVESET_DATA, absl, fullname, "") # type: ignore[w]
    output["name"]=fullname
    util.write(f"gh-pages/wavesets/{absl}.json",json.dumps(output,indent=2))
    context = {
        "name": f'<a href="waveset_viewer.html?w={absl}.json">{cfgfile.replace("construction/","").replace("construction_rift/","")}</a>',
        "desc": f'{key_text}'
    }

    info_html += util.fill_template(util.read(f"templates/rogue/rogue_encounter{"_nodesc"*int(len(key_text)==0)}.html"),context)

    return info_html

def parse_random_music(obj: dict[str, Any]):
    """
    "0"
    {
        "file"		"#zombiesurvival/construct/wilderness_1.mp3" [1]
        "time"		"183"
        "download"	"1"
        "name"		"The Wilderness"
        "author"	"Kenneth Young & Mat Clark"

        "interactive" (NOTE show as e.g. 'ByRandom: The Wilderness - Kenneth Young & Mat Clark') [2]
        {
            "#zombiesurvival/construct/wilderness_2.mp3"	"InterMusic_ConstructIntencity"
            "#zombiesurvival/construct/wilderness_3.mp3"	"InterMusic_ConstructBase"
            "#zombiesurvival/construct/wilderness_4.mp3"	"InterMusic_ByRandom"
            "#zombiesurvival/construct/wilderness_5.mp3"	"InterMusic_ConstructRisk"
            "#zombiesurvival/construct/wilderness_6.mp3"	"InterMusic_ByAlone"
        }
    }
    """
    out = ""

    # Base music [1]
    modal = util.music_modal(obj)
    assert modal is not None
    MUSIC_BY_TITLE[modal["musictitle"]] = modal
    out += util.musicmodal_to_html(modal)

    if "interactive" in obj:
        for file, case in obj["interactive"].items():
            objc=obj.copy()
            objc["file"] = file
            modal = util.music_modal(objc)
            out += f'<div style="margin:1em;"><span class="secondary">{case.split("_")[1]}:</span> {util.musicmodal_to_html(modal)}</div>'

    return out


### CONST 1 ###
def parse_const1(name: str, data: dict[str, Any], html_mapsets: str) -> tuple[str, str]:
    """
    # Const1 Structure
    Construction
        Setup
            cash [int] ✓
            Starting [rogue_item_modal arr] ✓
                Pickaxes and a Map => name+desc keys
        Construction
            Artifacts [rogue_item_modal arr] ✓
            Research [parse_const_research arr]
                "Tranquilizer Turret"
                {
                    "key"	"Base Level I"
                    "time"	"40.0"

                    "cost"
                    {
                        "water"	"40"
                        "wizuh"	"10"
                    }
                }
            Attacks ✓ same as rogue
                "0"	// Wave ~1
                {
                    "construction/0_1"	""
                    "construction/0_2"	""
                    "construction/0_3"	""
                }
            FinalAttack ✓ same as rogue
                "construction/ending1_final"	"Expidonsa Tech Chip Install" (possibly the item you get on win?)
            resourcecount	"50"	// Max amount of resources ✓
            Resources [parse_const_resource arr]	// Randomly Spawning Resources ✓
                "npc_material_wood"
                {
                    "distance"	"500.0"	// Min distance away from base
                    "common"	"1"		// How more likely compared to other resources
                    "health"	"3000"	// Base health (gets scaled with players and risk)
                    "defense"	"-100"	// Min damage needed (does not get scaled)
                }
            AttackDrops	// Loot from Attacks (too much to document?) ✗
            RandomMusic ✓
                "0"
                {
                    "file"		"#zombiesurvival/construct/wilderness_1.mp3"
                    "time"		"183"
                    "download"	"1"
                    "name"		"The Wilderness"
                    "author"	"Kenneth Young & Mat Clark"

                    "interactive" (NOTE show as e.g. 'ByRandom: The Wilderness - Kenneth Young & Mat Clark')
                    {
                        "#zombiesurvival/construct/wilderness_2.mp3"	"InterMusic_ConstructIntencity"
                        "#zombiesurvival/construct/wilderness_3.mp3"	"InterMusic_ConstructBase"
                        "#zombiesurvival/construct/wilderness_4.mp3"	"InterMusic_ByRandom"
                        "#zombiesurvival/construct/wilderness_5.mp3"	"InterMusic_ConstructRisk"
                        "#zombiesurvival/construct/wilderness_6.mp3"	"InterMusic_ByAlone"
                    }
                }
    """
    info_html = ""

    # Starting Artifacts
    info_html += "<h2>Starting Artifacts</h2>\n"
    for artifact in data["Setup"]["Starting"].keys():
        info_html += rogue_item_modal(artifact)

    # All Artifacts
    info_html += "<h2>Artifacts</h2>\n"
    info_html += "<ul>\n"
    for artifact, a_data in data["Construction"]["Artifacts"].items():
        if defaultdict(str, a_data)["hidden"]=="1":
            continue
        info_html += rogue_item_modal(artifact,a_data)
        ARTIFACTS.append(artifact_json(artifact,a_data, "Construction 1"))
    info_html += "</ul>\n"

    # All Research
    info_html += "<h2>Research</h2>\n"
    info_html += "<ul>\n"
    for research in data["Construction"]["Research"]:
        if defaultdict(str, data["Construction"]["Research"][research])["hidden"]=="1":
            continue
        info_html += parse_const_research(research,data["Construction"]["Research"][research])
    info_html += "</ul>\n"

    # All Resources
    info_html += f"<h2>Resources</h2>\n<div>Max resources: {data["Construction"]["resourcecount"]}"
    info_html += "<ul>\n"
    for resource in data["Construction"]["Resources"]:
        info_html += parse_const_resource(resource,data["Construction"]["Resources"][resource])
    info_html += "</ul>\n"

    # Random music
    info_html += "<h2>Music</h2>\n<div>Different cases have different parts of a song.</div>\n"
    info_html += "<ul>\n"
    for music in data["Construction"]["RandomMusic"]:
        info_html += parse_random_music(data["Construction"]["RandomMusic"][music])
    info_html += "</ul>\n"

    # Attacks
    info_html += "<h2>Attacks</h2>\n"
    attacknum = "?"
    for attacknum, waves in data["Construction"]["Attacks"].items():
        info_html += f"<h3>Attack {attacknum}</h3>\n"

        info_html += "<ul>\n"
        for file,keyonwin in waves.items():
            info_html = parse_const_stage(info_html,file,keyonwin,attacknum,1)
        info_html += "</ul>\n"

    info_html += "<h2>Final Attack</h2>\n"
    info_html += "<ul>\n"
    for file, keyonwin in data["Construction"]["FinalAttack"].items():
        info_html = parse_const_stage(info_html, file, keyonwin, attacknum, 1)
    info_html += "</ul>\n"

    # List in construction.html
    n = name.split("/")[-1].replace(".cfg","")
    html_mapsets += f"<li><a href=\"{n}.html\">{n} - Construction 1</a></li>"


    wd = defaultdict(str,data)
    context = { # startcash, wavesetlistdata
        "startcash": wd["Setup"]["cash"],
        "wavesetlistname": "Construction 1",
        "wavesetlistdata": info_html,
        "character_hired_by": util.apply_morecolors(DEFAULT_MISSION_CLIENT)
    }
    HTML_WAVESET_LIST = util.fill_template(util.read("templates/rogue/roguedata.html"),context)
    # HTML_WAVESET_LIST -> what will be linked to on the ZR: rogue page
    # html_mapsets ->
    return HTML_WAVESET_LIST, html_mapsets

def parse_const_research(name: str, obj: dict[str, Any]):
    dd=defaultdict(str,obj)
    key_text = f"<div>Required research: {dd["key"]}</div>\n" if dd["key"]!="" else ""
    fulldesc = key_text + util.get_key(f"{name} Desc")

    cost_text = ""
    for item,amt in obj["cost"].items():
        cost_text += f"<div>{amt} {util.html_img(modules.shared.get_npc_icon(f"material_{item}"))} {item.title()}</div>"
    context = {
        "cost": cost_text,
        "name": util.get_key(name),
        "desc": util.divfornewline(util.apply_morecolors(fulldesc))
    }
    return util.fill_template(util.read("templates/const/const_item.html"),context)

def parse_const_resource(name: str, obj: dict[str, str]):
    """
    "npc_material_wood"
    {
        "distance"	"500.0"	// Min distance away from base
        "common"	"1"		// How more likely compared to other resources
        "health"	"3000"	// Base health (gets scaled with players and risk)
        "defense"	"-100"	// Min damage needed (does not get scaled)
    }
    """
    # materials have no description, npc data only used for icons
    npcinfo = NPCS_BY_FILENAME[name]
    context = {
        "name": util.html_img(modules.shared.get_npc_icon(npcinfo.icon)) + util.get_key(npcinfo.name),
        "cost": "",
        "desc": f"""<div>Min. distance away from base: {obj["distance"]}hu</div>
                <div>Appearance rate: {obj["common"]}</div>
                <div>Health: {obj["health"]}HP (scaling)</div>
                <div>Min. damage required: {obj["defense"]}HP (no scaling)</div>
                """
    }
    return util.fill_template(util.read("templates/const/const_item.html"),context)


### CONST 2 ###
def parse_const2(name: str, data: dict[str, Any], html_mapsets: str) -> tuple[str, str]:
    """
    # Const 2 Structure
    Construction
        Setup
            cash ✓
            Starting [rogue_item_modal arr] ✓
                level                item on win
                "Dungeon Level 3"	"Foreign Expidonsan Chip"
        Dungeon
            music_setup
            Artifacts (same as rogue) ✓
            Raids (same as rogue) ✓
                "4"
                {
                    "dungeon/final_expidonsa"	""
                    "dungeon/final_space"		"Expidonsa Space Beacon"
                }
            Bases
                "Normal Base 1"
                {
                    "common"		"4"				// How common is this room
                    "victory"		"2"				// How many loot upon winning
                    "wavechance"	"0.5"			// Chance of gaining a loot after passing a wave
                    "waveamount"	"1"				// Max loot rolls per wave pass
                    "lootscale"		"0.0"			// Battle wave scaling increase per loot obtained
                    "spawn"			"enemy_base_main"	// Player spawn
                    "cooldown"		"0.0"		// Room cooldown from appearing in vote
                    "minwave"		"0"			// Min wave scaling to appear in vote
                    "maxwave"		"999"		// Max wave scaling to appear in vote
                    "minattack"		"0"			// Min raid attacks to appear in vote
                    "maxattack"		"0"			// Max raid attacks to appear in vote
                    "key"			""			// Required artifact/function call
                    "func_start"	""

                    "Fights"
                    {
                        // Rated by wave number scaling
                        "dungeon/base_1_1"	"10"
                    }
                    "Loots"
                    {
                        // Rated by how common
                        "Wooden Crate"			"120"
                        "Jalan Crate"			"19"
                        "Wizuh Crate"			"19"
                        "Ossunia Crate"			"19"
                        "Sealed Jalan Crate"	"1"
                        "Sealed Wizuh Crate"	"1"
                        "Sealed Ossunia Crate"	"1"
                    }
                }
            Rooms (dungeon rooms?)
                "Common Dungeon 1"
                {
                    "common"		"4"
                    "victory"		"2"
                    "wavechance"	"1.0"
                    "waveamount"	"2"
                    "lootscale"		"0.31"
                    "spawn"			"dungeon_1_start"

                    "Fights"
                    {
                        "dungeon/spawners/difficulty_1/fight_1/dungeon_1_1"	"15"
                        "dungeon/spawners/difficulty_3/fight_1/dungeon_1_1"	"30"
                    }
                    "Loots"
                    {
                        "Wooden Crate"			"120"
                        "Jalan Crate"			"19"
                        "Wizuh Crate"			"19"
                        "Ossunia Crate"			"19"
                        "Sealed Jalan Crate"	"1"
                        "Sealed Wizuh Crate"	"1"
                        "Sealed Ossunia Crate"	"1"
                    }
                }
                "Shop"
                {
                    "common"		"2"
                    "spawn"			"dungeon_3_start"
                    "cooldown"		"300.0"
                    "key"			""
                    "func_start"	"Dungeon_Encounter_Shop"
                }
            Loots
                "Wooden Pack"
                {
                    "count"	"1"	// Items gained
                    "bonus"	"0.0"	// Chance for a bonus item
                    "color"	"255 255 255 255"	// Entity color

                    "Items"
                    {
                        // Rated by how common
                        "Dungeon_Crate_Ammo"	"1"
                        "Dungeon_Crate_Wood"	"3"
                    }
                }
            RandomMusic w/o interactive ✓
    """
    info_html = ""


    # Starting Artifacts
    info_html += "<h2>Starting Artifacts</h2>\n"
    for artifact,keyonwin in data["Setup"]["Starting"].items():
        info_html += rogue_item_modal(artifact,keyonwin)

    # All Artifacts
    info_html += "<h2>Artifacts</h2>\n"
    info_html += "<ul>\n"
    for artifact, a_data in data["Dungeon"]["Artifacts"].items():
        if defaultdict(str, a_data)["hidden"]=="1":
            continue
        info_html += rogue_item_modal(artifact,a_data)
        ARTIFACTS.append(artifact_json(artifact, a_data, "Construction 2"))
    info_html += "</ul>\n"

    # Random music
    info_html += "<h2>Music</h2>\n"
    info_html += "<ul>\n"
    # Setup Music
    modal = util.music_modal(data["Dungeon"]["music_setup"])
    assert modal is not None
    MUSIC_BY_TITLE[modal["musictitle"]] = modal
    info_html += f"Setup: {util.musicmodal_to_html(modal)}"
    for music in data["Dungeon"]["RandomMusic"]:
        info_html += parse_random_music(data["Dungeon"]["RandomMusic"][music])
    info_html += "</ul>\n"

    # Raids
    info_html += "<h2>Raids</h2>\n"
    for attacknum, waves in data["Dungeon"]["Raids"].items():
        try:
            int(attacknum)
        except ValueError:
            continue

        info_html += f"<h3>Attack {attacknum}</h3>\n"

        info_html += "<ul>\n"
        for file,keyonwin in waves.items():
            info_html = parse_const_stage(info_html,file,keyonwin,attacknum,2)
        info_html += "</ul>\n"

    # List in construction.html
    n = name.split("/")[-1].replace(".cfg","")
    html_mapsets += f"<li><a href=\"{n}.html\">{n} - Construction 2</a></li>"

    wd = defaultdict(str,data)
    context = {
        "startcash": wd["Setup"]["cash"],
        "wavesetlistname": "Construction 2 (incomplete info)",
        "wavesetlistdata": info_html,
        "character_hired_by": util.apply_morecolors("{white}Bob the First") # Hardcoding :D
    }
    HTML_WAVESET_LIST = util.fill_template(util.read("templates/rogue/roguedata.html"),context)

    return HTML_WAVESET_LIST,html_mapsets


PATH_NPC = "./TF2-Zombie-Riot/addons/sourcemod/scripting/zombie_riot/npc/"

util.log("Fetching base data...")
NPCS_BY_FILENAME, NPCS_BY_CATEGORY = parse_all_npcs()
DEFAULT_CASH_BY_WAVE = parse_default_cash()
DEFAULT_MISSION_CLIENT = parse_default_mission_client()
MUSIC_BY_TITLE = {}
ARTIFACTS = []
COMPLETE_ITEM_MAP = {}

cfg_files = {
    "classic.cfg": "gh-pages/survival.html",
    "fastmode.cfg": "gh-pages/raidrush.html",
}
for file in sorted(os.listdir("./TF2-Zombie-Riot/addons/sourcemod/configs/zombie_riot/maps/")):
    if ".cfg" in file:
        cfg_files[f"maps/{file}"] = None

html_specialmaps = ""
html_otherset = {}
for f,n in cfg_files.items():
    html_specialmaps, html_otherset = parse_waveset_list_cfg(f, html_specialmaps, html_otherset, filename_md=n)

util.write("gh-pages/data/npcs_by_category.json", json.dumps(NPCS_BY_CATEGORY,indent=2))
util.write("gh-pages/data/music_by_title.json", json.dumps(MUSIC_BY_TITLE,indent=2))
util.write("gh-pages/data/artifacts.json", json.dumps(ARTIFACTS,indent=2))
util.write("gh-pages/data/complete_item_map.json", json.dumps(COMPLETE_ITEM_MAP,indent=2))

# Get current commit SHA for TF2-Zombie-Riot
COMMIT_SHA = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd="TF2-Zombie-Riot").strip().decode("utf-8")
COMMIT_SHA_SHORT = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd="TF2-Zombie-Riot").strip().decode("utf-8")

context = {
    "wavesetlistdata": html_specialmaps, # list of mapset_overview templates
    "wavesetlistname": "Special Maps"
}
util.write("gh-pages/special.html", util.fill_template(util.read("templates/waveset/mapset_list.html"), context))

for name, html in html_otherset.items():
    context = {
        "wavesetlistdata": html,
        "wavesetlistname": name
    }
    util.write(f"gh-pages/{name.lower()}.html", util.fill_template(util.read("templates/waveset/mapset_list.html"),context))

context = {
    "parse_run": f"\n<sub>Code parsed at {datetime.now().strftime('%H:%M:%S %d.%m.%Y')} H:M:S D.M.Y {time.tzname[time.daylight]}</sub><br><sub>Source repository commit <a href=\"https://github.com/artvin01/TF2-Zombie-Riot/commit/{COMMIT_SHA}\">artvin01/TF2-Zombie-Riot@{COMMIT_SHA_SHORT}</a></sub>",
}
util.write("gh-pages/index.html", util.fill_template(util.read("templates/index.html"),context))
