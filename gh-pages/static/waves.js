let wave = 1;
let max_waves = 40; // TODO apply fake max_waves
let waveset = "";
let waveset_file = null;
let waveset_data = null;
const npc_html = `<div tabindex="0" class="wave_npc">
    npcimg
    <div class="wave_npc_count">npccount</div>

    <div class="tooltip">
        npcdata
    </div>
</div>`
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
        console.log("Max waves:"+max_waves);
        console.log("Fetched "+waveset_file);
        update_wave_display();
    } catch (error) {
        console.error(error.message);
    }
}

// https://stackoverflow.com/a/42111623
document.getElementById('wave_progress_bar').onclick = function(e) {
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
    max_wave_text.innerHTML = max_waves;
    wave_bar.style.width = (wave/max_waves)*100 + "%";

    if (wave===max_waves) {
        wave_bar.style["border-radius"] = "5px"; 
    } else {
        wave_bar.style["border-radius"] = "5px 0px 0px 5px";
    }

    document.title = "ZR Encyclopedia - " + waveset_data["name"];
    waveset_name_inner.innerHTML = waveset_data["name"];

    const container = document.getElementById("npc_container");
    let new_html = ""
    waveset_data["waves"][String(wave)].forEach(function (npc, _) {
        const context = {
            "npcimg": npc["img"],
            "npccount": npc["count"],
            "npcdata": "<h2>" + npc["prefix"] + npc["display_name"] + "</h2>" + npc["extra_info"]
        }
        new_html += fill_template(npc_html, context);
    });
    container.innerHTML = new_html
}

function fill_template(temp, cont) {
    for (let pair of Object.entries(cont)) {
        temp = temp.replace(pair[0],pair[1]);
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

let paramString = window.location.href.split('?')[1];
let queryString = new URLSearchParams(paramString);
for (let pair of queryString.entries()) {
    if (pair[0]=="w") { parse_waveset(pair[1]) };
    if (pair[0]=="wv") { set_wave(pair[1]) };
}

/* Accessibility */
document.onkeydown = (e) => {
  if (e.key === "Enter") {
    document.activeElement.click();
  }
};