let wave = 1;
let max_waves = 40;
let waveset = "";
let waveset_file = null;
let waveset_data = null;
const MUSIC_ICON = create_element("img", {"src": "static/img/music.svg"});

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
    waveset_file = `wavesets/${file}`;
    try {
        const response = await fetch(waveset_file);
        if (!response.ok) {
            throw new Error(`[parse_waveset] Response status: ${response.status}`);
        }

        waveset_data = await response.json();
    } catch (error) {
        console.error(`[parse_waveset] ${error.message}`);
    }

    max_waves = Number(Object.keys(waveset_data["waves"]).reduce((a, b) => Number(a) > Number(b) ? a : b));

    // wait until morecolors.js loads
    while(typeof apply_morecolors !== "function") {
        await sleep(1000);
    }

    const waveset_info_container = document.getElementById("waveset_info");
    const wd_template = {
        "authors.npc": "NPCs by: %s",
        "authors.format": "Format by: %s",
        "authors.raid": "Raidboss by: %s",
        "item_on_win": "Item on win: %s",
        "character_hired_by": "Hired by: %m", // Not usually shown in chat but rather in revive messages
        "desc": "%s"
    }
    for (const [key, entry] of Object.entries(wd_template)) {
        let val = key.split('.').reduce((p,c)=>p&&p[c]||null, waveset_data);
        if (val!==null) {
            waveset_info_container.appendChild(create_element("div",{"innerHTML": entry.replace("%s",val).replace("%m",apply_morecolors(val))}))
        }
    }

    for (const [key, entry] of Object.entries(waveset_data["music"])) {
        let m_pre = key.split("_")[1];
        let m_title =  apply_morecolors(entry["musictitle"].replace("|",""));
        let m_artist = apply_morecolors(entry["musicartist"]);
        let m_content = `${m_pre}: ${m_title} - ${m_artist}`;
        let modal = create_element("div", {"class": "audio"});
        modal.appendChild(MUSIC_ICON.cloneNode(true));
        modal.appendChild(create_element("span", {"innerHTML": m_content}));
        if (!entry["file_exists"]) {
            modal.classList.add("disabled");
        } else {
            modal.dataset.file = entry.filepath;
            modal.dataset.title = m_title;
            modal.dataset.artist = m_artist;
            modal.addEventListener("click", event => {
                set_audio_resource(event.target);
            })
        }
        waveset_info_container.appendChild(modal);
    };

    if (waveset_info_container.children.length > 1) {
        waveset_info_container.parentElement.classList.remove("hidden");
    }

    console.log(`[parse_waveset] Max waves:${max_waves}`);
    console.log(`[parse_waveset] Fetched ${waveset_file}`);
    update_wave_display();
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
        max_wave_text.innerHTML = `${max_waves} (${waveset_data["fakemaxwaves"]})`; // set fake max waves but not internally
    } else {
        max_wave_text.innerHTML = max_waves;
    }
    wave_bar.style.width = `${(wave/max_waves)*100}%`;

    if (wave===max_waves) {
        wave_bar.style["border-radius"] = "5px";
    } else {
        wave_bar.style["border-radius"] = "5px 0px 0px 5px";
    }

    document.title = `ZR Encyclopedia - ${waveset_data["name"]}`;
    waveset_name_inner.innerHTML = waveset_data["name"];

    const npc_container = document.getElementById("npc_container");
    let support_npc_list = [];
    const wave_info_container = document.getElementById("wave_info_container");
    const wave_music_container = document.getElementById("wave_music_container");

    empty_element(npc_container);
    empty_element(wave_info_container);
    empty_element(wave_music_container);

    // entry types: npc, music, info
    waveset_data["waves"][String(wave)].forEach(function (entry, _) {
        if (entry["type"] === "npc") {
            let npc_modal = create_element("div", {"class": `wave_npc ${entry.css_class}`, "tabIndex": "0"}); // tabIndex neeeded such that one can click on the npc and pick a song from it (css :focus property)
            npc_modal.appendChild(create_element("img", {"src": entry.img}));
            npc_modal.appendChild(create_element("div", {"class": "wave_npc_count", "innerHTML": entry.count}));

            let tooltip_container = create_element("div", {"class": "tooltip"});
                tooltip_container.appendChild(create_element("h2", {"innerHTML": entry.prefix+entry.display_name}));
                tooltip_container.appendChild(create_element("span", {"innerHTML": entry.extra_info}));

            npc_modal.addEventListener("mouseover", event => {
                if (event.target.classList.contains("wave_npc")) {
                    let tooltip_container = event.target.getElementsByClassName("tooltip")[0];

                    /* do not switch sides every time */
                    tooltip_container.classList.remove("tooltip_toright");
                    tooltip_container.classList.remove("tooltip_toleft");
                    tooltip_container.offsetHeight;

                    tooltip_bbox = tooltip_container.getBoundingClientRect();

                    // absolute jank
                    if (tooltip_bbox.left < 0) {
                        tooltip_container.classList.add("notr-right");tooltip_container.offsetHeight;tooltip_container.classList.remove("notr-right");
                        tooltip_container.classList.add("tooltip_toright");
                    } else if (tooltip_bbox.right > window.innerWidth) {
                        tooltip_container.classList.add("notr-left");tooltip_container.offsetHeight;tooltip_container.classList.remove("notr-left");
                        tooltip_container.classList.add("tooltip_toleft");
                    } else {
                        tooltip_container.classList.add("notr-default");tooltip_container.offsetHeight;tooltip_container.classList.remove("notr-default");
                        tooltip_container.classList.remove("tooltip_toright");
                        tooltip_container.classList.remove("tooltip_toleft");
                    }
                    tooltip_container.offsetHeight;
                }
            })

            npc_modal.appendChild(tooltip_container);

            let is_support = entry["css_class"].includes("flag_support") || entry["css_class"].includes("flag_support_limited") || entry["css_class"].includes("flag_mission");
            if (is_support) {
                support_npc_list.push(npc_modal);
            } else {
                npc_container.appendChild(npc_modal);
            }
        } else if (entry["type"]=="music") {
            let m_title =  apply_morecolors(entry["musictitle"].replace("|",""));
            let m_artist = apply_morecolors(entry["musicartist"]);
            let m_content = `${m_title} - ${m_artist}`;
            let music_modal = create_element("div", {"class": "audio"});
            music_modal.appendChild(MUSIC_ICON.cloneNode(true));
            music_modal.appendChild(create_element("span", {"innerHTML": m_content}));
            if (!entry["file_exists"]) {
                music_modal.classList.add("disabled");
            } else {
                music_modal.dataset.file = entry.filepath;
                music_modal.dataset.title = m_title;
                music_modal.dataset.artist = m_artist;
                music_modal.addEventListener("click", event => {
                    set_audio_resource(event.target);
                })
            }
            wave_music_container.appendChild(music_modal);
        } else if (entry["type"]=="info") {
            wave_info_container.appendChild(create_element("div",{"innerHTML": `${entry["text"]}\n`}));
        }
    });

    if (support_npc_list.length > 0) {
        let support_npc_container = create_element("div", {"id": "support_npc_container"});
        if (support_npc_list.length > 1) { support_npc_container.style["margin-left"]="-43px" };
        support_npc_list.forEach(npc_modal => {
            support_npc_container.appendChild(npc_modal);
        });
        support_npc_container.appendChild(create_element("div",{"class": "flex_break"}));
        support_npc_container.appendChild(create_element("h2",{"innerHTML": "SUPPORT"}));

        npc_container.appendChild(create_element("div",{"class": "divider"}));
        npc_container.appendChild(support_npc_container);
    };
}

function fill_template(temp, cont) {
    for (let pair of Object.entries(cont)) {
        temp = temp.replaceAll(pair[0],pair[1]);
    }
    return temp
}

function copy_waveset_embed_link(event) {
    let source_url = window.location.href.substring(0,  window.location.href.lastIndexOf('/'));;
    navigator.clipboard.writeText(`${source_url}/embed/${waveset_file.split(".json")[0].split("/")[1]}_${wave}.gif`);

    let notification = create_element("div",{"class": "notify_copied", "innerHTML": "Embed link copied!"});
    notification.style.setProperty("--top",`${event.clientY + window.scrollY - 32}px`);
    notification = document.body.appendChild(notification);
    notification.style["left"] = `${event.clientX - (notification.getBoundingClientRect().width/2)}px`;
    setTimeout(function(notification){
        notification.remove();
    }, 1000, notification)
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


// lib
// TODO unified lib js
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function create_element(tag, attributes) {
    let element = document.createElement(tag);
    for (let val in attributes) {
        if (element.setAttribute) {
            if (val==="class") {
                element.classList.add(...attributes[val].split(" ").filter(i => i));
            } else if (element[val] in element) {
               element.setAttribute(val, attributes[val]);
            } else {
                element[val] = attributes[val];
            }
        } else {
            element[val] = attributes[val];
        }
    }
    return element;
}

function empty_element(el) {
    while (el.firstChild) { el.removeChild(el.firstChild) };
}

/* Accessibility */
document.onkeydown = (e) => {
  if (e.key === "Enter") {
    document.activeElement.click();
  }
};

check_url_params();
