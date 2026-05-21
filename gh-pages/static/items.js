/*
Entry types:
weapon (may also be kit)
weaponpap
trophy
perk
upgrade
*/

// TODO toggle for hidden weapons

let item_data = [];
let item_by_id = {};
let item_by_contents = {};
const ATTRIBUTE_TYPES = ["positive", "negative", "neutral"] // order important

async function parse_items() {
    async function item_block(parent_element,parent_data) {
        for (const [category, data] of Object.entries(parent_data)) {
            if (isUppercase(category)) { // nest
                block = document.createElement("div");
                block.classList.add("block");
                block.innerHTML = `<h1>${category}</h1>`
                await item_block(parent_element.appendChild(block), data);
            } 
            if (category==="$items") {
                await parse_item_list(parent_element, data)
            }

            if (category==="$description") {
                container = block.appendChild(create_element("div","block-desc_container"))
                data.forEach(element => {
                    desc_el = document.createElement("div");desc_el.innerHTML=element;
                    desc_el.classList.add("block-desc");
                    container.appendChild(desc_el);
                });
            }
        }
    }

    await item_block(document.body, item_data);
    interface_goto(...check_url_params())
}

async function parse_item_list(parent_element, item_data) {
    item_grid = document.createElement("div")
    item_grid.classList.add("item_grid")
    item_grid = parent_element.appendChild(item_grid);
    for (const item of item_data) {
        iter_item(item_grid, item, true);
    }
}

function iter_item(parent_element, item, sw_opt) {
    item_el = parent_element.appendChild(create_element("div", "item_instance"));
    //console.log(`Load item ${item["name"]}`);

    /* Add icon to item instance */
    if (Boolean(item["icon"])) {
        item_icon = create_element("img", "item_icon")
        item_icon.src = item["icon"];
        item_el.appendChild(item_icon);
    } else if (item["type"]=="weaponkit") { // weaponkit subweapon icon carousel
        kit_container = item_el.appendChild(create_element("div", "kit_icon_container"));
        const max = item["subweapons"]["items"].length;

        // Detect if there is at least one existing icon
        let has_existing_icons = false;
        item["subweapons"]["items"].forEach(subweapon => { if (Boolean(subweapon.icon)) { has_existing_icons=true; } });
        
        item["subweapons"]["items"].forEach((subweapon, idx) => {
            if (Boolean(subweapon["icon"])) { // Insert rendered icon
                item_icon = create_element("img", "item_icon kit_icon");
                item_icon.src = subweapon["icon"]
                kit_container.appendChild(item_icon);
            } else if ((max==1) || !has_existing_icons) { // Insert missing icon
                insert_svg("builtin_img/missing_item.svg", "#b2b2b2", "item_icon kit_icon", kit_container);
            }
        });
    } else {
        switch (item["type"]) {
            case "trophy":
                icon_path = "builtin_img/award.svg";
                break;
            case "barrack":
                icon_path = "builtin_img/users.svg";
                break;
            case "perk":
                icon_path = "builtin_img/arrow-up-circle.svg";
                break;
            case "upgrade":
                icon_path = "builtin_img/chevrons-up.svg";
                break;
            default:
                icon_path = "builtin_img/missing_item.svg";
        } 
        insert_svg(icon_path, "#b2b2b2", "item_icon", item_el);
    }

    /* Add price tag */
    tag = item["cost"]
    if (tag === "Free" && Boolean(item["lvl"])) {
        tag = `LVL${item["lvl"]}`
    }
    item_el.appendChild(create_element("div", "item_price", tag))

    /* Add item tooltip */
    item_tooltip = item_el.appendChild(create_element("div", "item_tooltip"));
    
    /* Item name */
    item_tooltip.appendChild(create_element("h2", "", item["name"]));
    
    /* Tags */
    if ("tags" in item) {
        item_tooltip.appendChild(create_element("div", "secondary", item["tags"].join(" ")));
    }

    /* Author */
    if (Boolean(item["author"])) {
        item_tooltip.appendChild(create_element("div", "secondary", apply_morecolors(item["author"])));
    };


    /* Add description */
    item["description"].split("\n").forEach(line => {
        item_tooltip.appendChild(create_element("div", "", line));
    });

    /* Add attributes */
    if ("attributes" in item && item["type"] !== "perk") {
        if (Object.keys(item["attributes"]).length>0) {
            attribute_container = item_tooltip.appendChild(create_element("div", "attribute_container"));
            ATTRIBUTE_TYPES.forEach(attr_type => {
                if (attr_type in item["attributes"]) {
                    item["attributes"][attr_type].forEach(attribute => {
                        attribute.split("\n").forEach(line => {
                            attribute_container.appendChild(create_element("div",`attribute_line ${attr_type}`,line));
                        });
                    });
                };
            });
        };
    };

    /* Subweapon viewing functionality */
    /* Map item to an id (Viewing subweapons, Weapon selectors) */
    item_el.dataset.id = item.wid;
    if (sw_opt) { // popup on click
        item_by_id[item.wid] = item
        contents = [
            item.name,
            item.description
        ]
        if (item.tags!==undefined) {
            contents.push(item.tags.join(" "));
        }
        item_by_contents[contents.join(" ")] = item
        if ("subweapons" in item) { 
            if ("items" in item["subweapons"]) {
                    item_el.style["cursor"] = "pointer";
                    item_tooltip.appendChild(create_element("div", "secondary item_notice", `Click to view ${item["subweapons"]["name"]}`)) // Show "Click to view Weapon Enhancements/Kit Items" in tooltip
                    
                    item_el.addEventListener("click", (event) => {
                        item = item_by_id[event.target.dataset.id];
                        open_subweapon_modal(item);
                        let bounds = swr_canvas.getBoundingClientRect();
                        mousepos[0] = event.clientX-bounds.left;
                        mousepos[1] = event.clientY-bounds.top;
                    });
                }
            }
    }

    /* Weapon selector clipboard shortcut */
    item_el.addEventListener("contextmenu", (event) => {
        event.preventDefault();
        let source_url = window.location.href.split('?')[0]; // get url w/o params
        navigator.clipboard.writeText(`${source_url}?wid=${event.target.dataset.id}`);
        
        let notification = create_element("div","notify_copied","Link copied!");
        notification.style.setProperty("--top",`${event.clientY + window.scrollY - 32}px`);
        notification = document.body.appendChild(notification);
        notification.style["left"] = `${event.clientX - (notification.getBoundingClientRect().width/2)}px`;
        setTimeout(function(notification){
            notification.remove();
        }, 1000, notification)
    });

    /* Prevent tooltips from going outside of viewport */
    // TODO add mousein/out events to each item_instance for tooltip recalc
    tooltip_bbox = item_tooltip.getBoundingClientRect();
    if (tooltip_bbox.left < 0) {
        item_tooltip.classList.add("item_tooltip_toright");
    } else if (tooltip_bbox.right > window.innerWidth) {
        item_tooltip.classList.add("item_tooltip_toleft");
    }
    return item_el
}

// INTERFACE ===================================================
async function interface_goto(wid,swid) {
    if (wid===null) {return}; // no params given
    const query = `[data-id='${wid}']`;
    const search = document.querySelectorAll(query)
    if (search.length===1) {
        // remove all existing highlights first & clear their timeouts
        let highlights = document.body.getElementsByClassName("highlight");
        while (highlights.length) {
            clearTimeout(highlights[0].dataset.timeout_id);
            delete highlights[0].dataset.timeout_id;
            highlights[0].classList.remove("highlight");
        }
        // highlight/open sw modal
        const welement = search[0];
        welement.scrollIntoView({"behavior": "smooth", "block": "center"});
        if (swid===null) { // No swid: Scroll weapon into view and highlight for 3s 
            welement.classList.add("highlight");
            welement.dataset.timeout_id = setTimeout(function(welement){
                welement.classList.remove("highlight");
            }, 3000, welement)
        } else { // Swid: Scroll to weapon, open swmodal and highlight
            open_subweapon_modal(item_by_id[wid]);
            swr_highlight = {"id":swid,"time":Date.now()+3000,"valid":false};
        }
    } else if (search.length>1) {
        console.warn("[interface_goto] Found multiple matches for weapon id!")
    } else {
        notif_container = document.body.appendChild(create_element("div","notify_container"));
        notification = notif_container.appendChild(create_element("div","notify_notfound","Weapon not found!"));
        notification.style.padding = "4px"; // no red dot before load
        setTimeout(function(notification){
            notification.remove();
        }, 2000, notif_container)
    }
}
async function open_subweapon_modal(item) {
    // modal container
    modal = create_element("div", "modal");
    modal.id = "sw_modal";
    modal = document.body.appendChild(modal);
    modal_content = modal.appendChild(create_element("div","subweapon_modal_content"));

    // title
    modal_content.appendChild(create_element("h1","",`${item["name"]}: ${item["subweapons"]["name"]}`));
    insert_svg("builtin_img/x.svg", "#ccc8c1", "close_button", modal_content, {
        "args": [],
        "func": function(element){
            element.addEventListener("click", (event) => {
                modal = document.getElementById("sw_modal");
                modal.remove();
            });
        }
    });

    // draggable container for subweapons
    swr_canvas = modal.appendChild(create_element("canvas","subweapon_container"));
    swr_item = item;
    swr_setup();
    reset_cam = true;
    window.requestAnimationFrame(draw);
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
    let haystack = Object.keys(item_by_contents);
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
            let item = item_by_contents[haystack[idx]];
            const item_el = iter_item(results_container, item, false);
            // tooltip text
            item_el.style["cursor"] = "pointer";
            const item_tooltip = item_el.getElementsByClassName("item_tooltip")[0]
            item_tooltip.appendChild(create_element("div", "secondary item_notice", `Click to go to weapon`));
            item_el.addEventListener("click", (event) => {
                document.getElementById("search_modal").remove();
                interface_goto(event.target.dataset.id,null);
            });
        });
    }
}

// REQUEST ===================================================
async function fetch_items() {
    data_file = `items/items.json`;
    try {
        const response = await fetch(data_file);
        if (!response.ok) {
            throw new Error(`[fetch_items] Response status: ${response.status}`);
        }

        item_data = await response.json();
    } catch (error) {
        console.error(`[fetch_items] ${error.message}`);
    }

    console.log(`[fetch_items] Fetched ${data_file}`);
    parse_items();
    //window.requestAnimationFrame(draw);
}

// LIB ===================================================
function isUppercase(word){
  return /^\p{Lu}/u.test( word );
}
function create_element(tag, classes, content) {
    content = content || "";
    el = document.createElement(tag);
    if (classes!=="" && classes!==undefined) { el.classList.add(...classes.split(" ")); }
    el.innerHTML = content;
    return el
}
let SVG_LIST = {};
async function load_svg(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);

        const svgText = await response.text();
        const parser = new DOMParser();
        const svgDoc = parser.parseFromString(svgText, 'image/svg+xml');
        const svgElement = svgDoc.documentElement;

        if (svgElement.tagName !== 'svg') {
            throw new Error('Parsed content is not an SVG');
        }

        console.log(`[load_svg] Success: ${url}`)
        return svgElement;
    } catch (error) {
        console.log(`[load_svg] Error: ${error}`)
    }
}
async function insert_svg(url, color, classes, parent, onload) {
    if (SVG_LIST[url]===undefined) {
        SVG_LIST[url] = load_svg(url);
    };
    const cached = await SVG_LIST[url];
    const svgElement = cached.cloneNode(true);
    svgElement.style.color = color;
    if (classes!="") { svgElement.classList.add(...classes.split(" ")) };
    new_el = parent.appendChild(svgElement);
    if (onload!==undefined) {
        onload["func"](new_el, ...onload["args"]);
    }
}
function check_url_params() {
    let queryString = new URLSearchParams(window.location.href.split('?')[1]);
    return [queryString.get("wid"), queryString.get("swid")] // null if empty
}

fetch_items();