let artifact_data = [];
let artifact_by_contents = {};
let filter_from = null;
const source_types = [
    "All",
    "Rogue 1",
    "Rogue 2",
    "Rogue 3",
    "Construction 1",
    "Construction 2",
]
/* NOTE if an item is hidden by filter it can still be searched for (same goes for items.js etc.) */

async function parse_items(goto = true) {
    let atfxlist = document.body.appendChild(create_element("ul", "fx_container"));
    artifact_data.forEach(artifact => {
        if (artifact.from === filter_from || filter_from===null) {
            atfxobject(atfxlist, artifact, true)
        }
    })
    if (goto) {interface_goto(new URLSearchParams(window.location.href.split('?')[1]).get("id"))};
}

function atfxobject(parent_element, artifact, root) {
    let atfxitem = parent_element.appendChild(create_element("li", "item_instance atfx_instance"));
    let atfx_name = create_element_adv("span", {"innerHTML": artifact.name, "class": "atfx_name"}) ;
    atfx_name.dataset.src = html_src(artifact.source.name);
    atfxitem.appendChild(atfx_name);
    let atfxtooltip = atfxitem.appendChild(create_element("div", "item_tooltip"));
    atfxtooltip.appendChild(create_element("div", "secondary", `From ${artifact.from}`));
    if ("shopcost" in artifact) {
        atfxtooltip.appendChild(create_element("div", "secondary", `Cost △ ${artifact.shopcost}`));
    }
    if ("dropchance" in artifact) {
        atfxtooltip.appendChild(create_element("div", "secondary", `Dropchance ${artifact.dropchance}`));
    }
    artifact.description.split("\n").forEach(line => {
        atfxtooltip.appendChild(create_element("div", "", apply_morecolors(line)));
    });

    atfxitem.dataset.id = artifact.id;
    if (root) {
        contents = [
            artifact.name,
            artifact.description
        ]
        artifact_by_contents[contents.join(" ")] = artifact

        /* Weapon selector clipboard shortcut */
        atfxitem.addEventListener("contextmenu", (event) => {
            event.preventDefault();
            let source_url = window.location.href.split('?')[0]; // get url w/o params
            navigator.clipboard.writeText(`${source_url}?id=${event.target.dataset.id}`);

            let notification = create_element("div","notify_copied","Link copied!");
            notification.style.setProperty("--top",`${event.clientY + window.scrollY - 32}px`);
            notification = document.body.appendChild(notification);
            notification.style["left"] = `${event.clientX - (notification.getBoundingClientRect().width/2)}px`;
            setTimeout(function(notification){
                notification.remove();
            }, 1000, notification)
        });
    }

    /* Prevent tooltips from going outside of viewport */
    /* TODO unified lib */
    atfxitem.addEventListener("mouseover", event => {
        let item_tooltip = event.target.getElementsByClassName("item_tooltip")[0];

        /* do not switch sides every time */
        item_tooltip.classList.remove("item_tooltip_toright");
        item_tooltip.classList.remove("item_tooltip_toleft");
        item_tooltip.offsetHeight;

        tooltip_bbox = item_tooltip.getBoundingClientRect();

        // absolute jank
        if (tooltip_bbox.left < 0) {
            item_tooltip.classList.add("notr-right");item_tooltip.offsetHeight;item_tooltip.classList.remove("notr-right");
            item_tooltip.classList.add("item_tooltip_toright");
        } else if (tooltip_bbox.right > window.innerWidth) {
            item_tooltip.classList.add("notr-left");item_tooltip.offsetHeight;item_tooltip.classList.remove("notr-left");
            item_tooltip.classList.add("item_tooltip_toleft");
        } else {
            item_tooltip.classList.add("notr-default");item_tooltip.offsetHeight;item_tooltip.classList.remove("notr-default");
            item_tooltip.classList.remove("item_tooltip_toright");
            item_tooltip.classList.remove("item_tooltip_toleft");
        }
        item_tooltip.offsetHeight;
    })
    return atfxitem
}

// INTERFACE ===================================================
async function update_items() {
    document.body.getElementsByClassName("fx_container")[0].remove();
    let artifacts_by_contents = {};
    await parse_items(false);
}
function set_tag(type, event) {
    if (type!==showpositive) {
        showpositive = type;
        document.getElementById(`fxtype${type}`).classList.add("active");
        document.getElementById(`fxtype${!type}`).classList.remove("active");
    } else if (type===showpositive) {
        showpositive = null
        document.getElementById(`fxtype${type}`).classList.remove("active");
    };
    update_items();
}

async function interface_goto(wid) {
    if (wid===null) {return}; // no params given
    console.log("goto",wid)
    const query = `[data-id='${wid}']`;
    const search = document.querySelectorAll(query)
    if (search.length===1) {
        // remove all existing highlights first & clear their timeouts
        let highlights = document.body.getElementsByClassName("highlight_bg");
        while (highlights.length) {
            clearTimeout(highlights[0].dataset.timeout_id);
            delete highlights[0].dataset.timeout_id;
            highlights[0].classList.remove("highlight_bg");
        }
        const welement = search[0];
        welement.scrollIntoView({"behavior": "smooth", "block": "center"});
        welement.classList.add("highlight_bg");
        welement.dataset.timeout_id = setTimeout(function(welement){
            welement.classList.remove("highlight_bg");
        }, 3000, welement);
    } else if (search.length>1) {
        notif_container = document.body.appendChild(create_element("div","notify_container"));
        notification = notif_container.appendChild(create_element("div","notify_notfound","Found multiple artifact matches!"));
        notification.style.padding = "4px"; // no red dot before load
        setTimeout(function(notification){
            notification.remove();
        }, 2000, notif_container)
        console.warn("[interface_goto] Found multiple matches for id!");
    } else {
        notif_container = document.body.appendChild(create_element("div","notify_container"));
        notification = notif_container.appendChild(create_element("div","notify_notfound","Artifact not found!"));
        notification.style.padding = "4px"; // no red dot before load
        setTimeout(function(notification){
            notification.remove();
        }, 2000, notif_container);
    }
}

// reference: https://unixpapa.com/js/key.html
document.addEventListener("keydown", (event) => {
    if (event.code==="KeyK" && event.ctrlKey) {
        event.preventDefault();  // Prevent Ctrl+K browser search keybind
        search_modal = document.getElementById("search_modal");
        if (search_modal === null) {
            open_search();
        } else {
            search_modal.remove();
        }
    };
    if (event.code==="Escape") {
        if ((search_modal = document.getElementById("search_modal")) !== null) {
            search_modal.remove();
        }
    }
    if (event.code==="Enter") {
        if ((search_results = document.getElementById("search_results")) !== null) {
            if (search_results.innerHTML.length > 0) {
                document.getElementById("search_modal").remove();
                interface_goto(search_results.getElementsByClassName("item_instance")[0].dataset.id,null) // get first item (best match) and go to it
            }
        }
    }
})

async function open_search() {
    modal = create_element("div", "modal");
    modal.addEventListener("click", function(){
        document.getElementById("search_modal").remove();
    })
    modal.id = "search_modal";
    modal = document.body.appendChild(modal);
    modal_container = modal.appendChild(create_element("div","search_modal_container"));
    modal_content = modal_container.appendChild(create_element("div","search_modal_content"));

    let search_bar = create_element("input");
    search_bar.type = "search";
    search_bar.addEventListener("click", (event)=>{event.stopPropagation()});
    search_bar.addEventListener("input", search);
    search_bar = modal_content.appendChild(search_bar);
    search_bar.focus();
}

async function search(event) {
    // get results container and create if not present
    let results_container = document.getElementById("search_results");
    if (results_container===null) {
        results_container = create_element("div","search_modal_results");
        results_container.id = "search_results";
        results_container.addEventListener("click", (event)=>{event.stopPropagation()});
        event.target.parentElement.appendChild(create_element("div","flex_break"));
        results_container = event.target.parentElement.appendChild(results_container);
    }
    results_container.innerHTML="";
    // From the uFuzzy example: https://github.com/leeoniya/uFuzzy
    let haystack = Object.keys(artifact_by_contents);
    let needle = event.target.value;
    let opts = {};
    let uf = new uFuzzy(opts);

    // pre-filter
    let idxs = uf.filter(haystack, needle);

    // idxs can be null when the needle is non-searchable (has no alpha-numeric chars)
    if (idxs != null && idxs.length > 0) {
        let info = uf.info(idxs, haystack, needle);

        // order is a double-indirection array (a re-order of the passed-in idxs)
        // this allows corresponding info to be grabbed directly by idx, if needed
        let order = uf.sort(info, haystack, needle).slice(0,30);

        // render post-filtered & ordered matches
        order.forEach((element, element_index) => {
            // using info.idx here instead of idxs because uf.info() may have
            // further reduced the initial idxs based on prefix/suffix rules
            let idx = info.idx[element];
            let item = artifact_by_contents[haystack[idx]];
            const item_el = atfxobject(results_container, item, false);
            // tooltip text
            item_el.style["cursor"] = "pointer";
            const item_tooltip = item_el.getElementsByClassName("item_tooltip")[0]
            item_tooltip.appendChild(create_element("div", "secondary item_notice", `Click to go to artifact`));
            item_el.addEventListener("click", (event) => {
                document.getElementById("search_modal").remove();
                interface_goto(event.target.dataset.id);
            });
        });
    }
}

// REQUEST ===================================================
async function fetch_atfx() {
    data_file = `data/artifacts.json`;
    try {
        const response = await fetch(data_file);
        if (!response.ok) {
            throw new Error(`[fetch_atfx] Response status: ${response.status}`);
        }

        artifact_data = await response.json();
    } catch (error) {
        console.error(`[fetch_atfx] ${error.message}`);
    }

    console.log(`[fetch_atfx] Fetched ${data_file}`);
    parse_items();
}

// LIB ===================================================
function create_element(tag, classes, content = "") {
    el = document.createElement(tag);
    if (classes!=="" && classes!==undefined) { el.classList.add(...classes.split(" ")); }
    el.innerHTML = content;
    return el
}
function create_element_adv(tag, attributes) {
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
/*
def html_src(src_obj: TypeSourceObject):
    """
    Return a TypeSourceObject as an HTML data-src attribute
    e.g. ("foo",1) -> "foo#L1"
         ("foo",[1,2]) -> "foo#L1-L2"
    """
    if type(src_obj[1]) is list:
        return f"{src_obj[0]}#L{src_obj[1][0]}-L{src_obj[1][1]}"
    else:
        return f"{src_obj[0]}#L{src_obj[1]}"
*/


/**
Return a TypeSourceObject as an HTML data-src attribute  
e.g. ("foo",1) -> "foo#L1"  
........("foo",[1,2]) -> "foo#L1-L2"  
 */
function html_src(src_obj) {
    if (typeof src_obj === Array) {
        return `${src_obj[0]}#L${src_obj[1][0]}-L${src_obj[1][1]}`;
    } else {
        return `${src_obj[0]}#L${src_obj[1]}`;
    }
}

// wait until morecolors.js loads
while(typeof apply_morecolors !== "function") {
    sleep(1000);
}

let src_dropdown = document.getElementById("gtags").appendChild(create_element("select", "gtag"));
src_dropdown.addEventListener("change", event => {
    if (event.target.value === "All") {
        filter_from = null;
    } else {
        filter_from = event.target.value;
    }
    update_items();
})
source_types.forEach(src => {
    src_dropdown.appendChild(create_element_adv("option", {"value": src, "innerHTML": src}));
})

fetch_atfx();
