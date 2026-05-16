/*
Entry types:
weapon (may also be kit)
weaponpap
trophy
perk
upgrade
*/

let item_data = [];
let item_by_id = {};
let global_cur_item_id = 0;
const ATTRIBUTE_TYPES = ["positive", "negative", "neutral"] // order important

async function parse_items() {
    /*
        parent_element: Which element the parsed contents of this run will be placed into.
    */
    async function item_block(parent_element,parent_data) {
        for (const [category, data] of Object.entries(parent_data)) {
            console.log(category);
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

    item_block(document.body, item_data);
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
    console.log(`Load item ${item["name"]}`);
    global_cur_item_id += 1;

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
    if ("subweapons" in item) {
        if ("items" in item["subweapons"]) {
            if (sw_opt) { // popup on click
                item_el.style["cursor"] = "pointer";
                item_tooltip.appendChild(create_element("div", "secondary item_notice", `Click to view ${item["subweapons"]["name"]}`)) // Show "Click to view Weapon Enhancements/Kit Items" in tooltip
                
                // map id to item data for future events
                item_by_id[global_cur_item_id] = item
                item_el.dataset.id = global_cur_item_id;
                
                item_el.addEventListener("click", (event) => {
                    console.log(`Clicked item ID ${event.target.dataset.id}`);
                    item = item_by_id[event.target.dataset.id];
                    // modal container
                    modal = create_element("div", "subweapon_modal");
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
                });
            }
        }
    }

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

// LIB
let SVG_LIST = {};
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

fetch_items();