let wave = 1;
let max_waves = 40;
let waveset = "";
let waveset_file = null;
let waveset_data = null;
const npc_modal = `<div tabindex="0" class="wave_npc $css_flags">
    npcimg
    <div class="wave_npc_count">npccount</div>

    <div class="tooltip">
        npcdata
    </div>
</div>
`
const support_npc_modal = `<div class="divider"></div><div id="support_npc_container" $offset>
    npcdata
    <div class="flex_break"></div>
    <h2>SUPPORT</h2>
</div>
`
const music_modal = `<div onclick="set_audio_resource(this);" file=\"filepath\" title=\"musictitle\" artist=\"musicartist\" class="audio"><img src="builtin_img/music.svg">musicpre musictitle musicartist</div>`
const music_modal_missing = `<div class="disabled audio"><img src="builtin_img/music.svg">musicpre musictitle musicartist</div>`
function cycle_wave(val) {
    let prev_wave = wave;
    wave = wave + val;
    if (wave>max_waves) {wave=max_waves};
    if (wave<1) {wave=1};
    if (prev_wave!==wave) { update_wave_display(); }
}

function set_wave(val) {
    let prev_wave = wave;
    let as_number = Number(val.replace(/\D/g,""));
    if (as_number>max_waves) {as_number=max_waves};
    if (as_number<1) {as_number=1};
    wave = as_number;
    if (prev_wave!==wave && waveset_data!==null) { update_wave_display(); }
}

async function parse_waveset(file) {
    waveset_file = "wavesets/"+file;
    try {
        const response = await fetch(waveset_file);
        if (!response.ok) {
            throw new Error(`Response status: ${response.status}`);
        }

        waveset_data = await response.json();
        max_waves = Number(Object.keys(waveset_data["waves"]).reduce((a, b) => Number(a) > Number(b) ? a : b));
        let waveset_info = "";
        if (waveset_data["authors"]["npc"]!=="") {waveset_info+="<div>NPCs by: %s</div>".replace("%s",waveset_data["authors"]["npc"])};
        if (waveset_data["authors"]["format"]!=="") {waveset_info+="<div>Format by: %s</div>".replace("%s",waveset_data["authors"]["format"])};
        if (waveset_data["authors"]["raid"]!=="") {waveset_info+="<div>Raidboss by: %s</div>".replace("%s",waveset_data["authors"]["raid"])};
        if (waveset_data["item_on_win"]!=="") {waveset_info+="<div>Item on win: %s</div>".replace("%s",waveset_data["item_on_win"])};
        
        for (const [key, entry] of Object.entries(waveset_data["music"])) {
            context = {
                "filepath": entry["filepath"],
                "filename": entry["filename"],
                "musicpre": key.split("_")[1] + ": ",
                "musictitle": entry["title"],
                "musicartist": entry["artist"]
            }
            if (!entry["file_exists"]) {
                waveset_info += fill_template(music_modal_missing, context);
            } else {
                waveset_info += fill_template(music_modal, context);
            }
        };

        const waveset_info_container = document.getElementById("waveset_info");
        if (waveset_info!=="") {
            console.log("unhide");
            waveset_info_container.parentElement.classList.remove("hidden");
            waveset_info_container.innerHTML = waveset_info;
        };

        console.log("Max waves:"+max_waves);
        console.log("Fetched "+waveset_file);
        update_wave_display();
    } catch (error) {
        console.error(error.message);
    }
}

function wavebar_setprogress(e) {
    let prev_wave = wave;
    const rect = e.target.getBoundingClientRect();
    let x = e.clientX - rect.left;
    wave = Math.round((x/(rect.right - rect.left)) * max_waves);
    if (wave<1) {wave=1};
    if (prev_wave!==wave) { update_wave_display(); }
}

function update_wave_display() {
    window.history.replaceState('', '', updateURLParameter(window.location.href, "wv", String(wave)));
    const wave_text = document.getElementById("wave_progress_text").getElementsByTagName("input")[0];
    const max_wave_text = document.getElementById("wave_progress_text").getElementsByTagName("span")[0];
    const wave_bar = document.getElementById("wave_progress_bar").getElementsByTagName("div")[0];
    const waveset_name_inner = document.getElementById("wavesetname");
    wave_text.value = wave;
    if (waveset_data["fakemaxwaves"] !== "") {
        max_wave_text.innerHTML = max_waves + " (" + waveset_data["fakemaxwaves"] + ")"; // set fake max waves but not internally
    } else {
        max_wave_text.innerHTML = max_waves;
    }
    wave_bar.style.width = (wave/max_waves)*100 + "%";

    if (wave===max_waves) {
        wave_bar.style["border-radius"] = "5px"; 
    } else {
        wave_bar.style["border-radius"] = "5px 0px 0px 5px";
    }

    document.title = "ZR Encyclopedia - " + waveset_data["name"];
    waveset_name_inner.innerHTML = waveset_data["name"];

    const npc_container = document.getElementById("npc_container");
    let npc_html = "";
    let support_npc_html = "";
    let support_npc_amt = 0;

    const wave_info_container = document.getElementById("wave_info_container");
    let wave_info_html = "";

    const wave_music_container = document.getElementById("wave_music_container");
    let wave_music_html = "";

    // entry types: npc, music, info
    waveset_data["waves"][String(wave)].forEach(function (entry, _) {
        if (entry["type"] === "npc") {
            const context = {
                "npcimg": entry["img"],
                "npccount": entry["count"],
                "npcdata": "<h2>" + entry["prefix"] + entry["display_name"] + "</h2>" + entry["extra_info"],
                "$css_flags": entry["css_class"]
            }
            let modal = fill_template(npc_modal, context);
            if (entry["is_support"]) {
                support_npc_html += modal;
                support_npc_amt += 1;
            } else {
                npc_html += modal;
            }
        } else if (entry["type"]=="music") {
            context = {
                "filepath": entry["filepath"],
                "filename": entry["filename"],
                "musicpre": "",
                "musictitle": entry["title"],
                "musicartist": entry["artist"]
            }
            if (!entry["file_exists"]) {
                wave_music_html += fill_template(music_modal_missing, context);
            } else {
                wave_music_html += fill_template(music_modal, context);
            }
        } else if (entry["type"]=="info") {
            wave_info_html += "<div>text</div>\n".replace("text",entry["text"]);
        }
    });

    wave_music_container.innerHTML = wave_music_html;

    wave_info_container.innerHTML = wave_info_html;

    if (support_npc_html!=="") {
        let support_npc_container_offset = "";
        if (support_npc_amt>1) { support_npc_container_offset="style=\"margin-left: -43px;\"" };
        context = {
            "npcdata":support_npc_html,
            "$offset":support_npc_container_offset
        }
        npc_html += fill_template(support_npc_modal, context);
    };

    npc_container.innerHTML = npc_html;
}

function fill_template(temp, cont) {
    for (let pair of Object.entries(cont)) {
        temp = temp.replaceAll(pair[0],pair[1]);
    }
    return temp
}

function copy_waveset_embed_link() {
    let source_url = window.location.href.substring(0,  window.location.href.lastIndexOf('/'));;
    copyTextToClipboard(source_url+"/embed/"+waveset_file.split(".json")[0].split("/")[1]+"_"+wave+".jpg");
}

// https://stackoverflow.com/a/30810322
function copyTextToClipboard(text) {
  if (!navigator.clipboard) {
    fallbackCopyTextToClipboard(text);
    return;
  }
  navigator.clipboard.writeText(text).then(function() {
    console.log('Async: Copying to clipboard was successful!');
  }, function(err) {
    console.error('Async: Could not copy text: ', err);
  });
}

// http://stackoverflow.com/a/10997390/11236
function updateURLParameter(url, param, paramVal){
    var newAdditionalURL = "";
    var tempArray = url.split("?");
    var baseURL = tempArray[0];
    var additionalURL = tempArray[1];
    var temp = "";
    if (additionalURL) {
        tempArray = additionalURL.split("&");
        for (var i=0; i<tempArray.length; i++){
            if(tempArray[i].split('=')[0] != param){
                newAdditionalURL += temp + tempArray[i];
                temp = "&";
            }
        }
    }

    var rows_txt = temp + "" + param + "=" + paramVal;
    return baseURL + "?" + newAdditionalURL + rows_txt;
}

async function check_url_params() {
    let queryString = new URLSearchParams(window.location.href.split('?')[1]);
    if (queryString.has("w")) {
        await parse_waveset(queryString.get("w"));
    }
    if (queryString.has("wv")) {
        set_wave(queryString.get("wv"));
    }
}

/* Accessibility */
document.onkeydown = (e) => {
  if (e.key === "Enter") {
    document.activeElement.click();
  }
};

check_url_params();