/*
Entry types:
weapon (may also be kit)
weaponpap
trophy
perk
upgrade
*/

let item_data = [];
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
        await iter_item(item);
    }
}

async function iter_item(item) {
    item_el = item_grid.appendChild(create_element("div", "item_instance"));
    
    /* Add icon to item instance */
    if (Boolean(item["icon"])) {
        item_icon = create_element("img", "item_icon")
        item_icon.src = item["icon"];
        item_el.appendChild(item_icon);
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
    /* + - 0 */
    
    if (Object.keys(item["attributes"]).length>0) {
        attribute_container = item_tooltip.appendChild(create_element("div", "attribute_container"));
        ATTRIBUTE_TYPES.forEach(attr_type => {
            if (attr_type in item["attributes"]) {
                item["attributes"][attr_type].forEach(attribute => {
                    attribute.split("\n").forEach(line => {
                        attribute_container.appendChild(create_element("div",`attribute_line ${attr_type}`,line));
                    });
                });
            }
        });
    }

    /* Prevent tooltips from going outside of viewport */
    // TODO recalculate on every window resize. inconvenient but I don't want to rewrite tooltips yet
    tooltip_bbox = item_tooltip.getBoundingClientRect();
    if (tooltip_bbox.left < 0) {
        item_tooltip.classList.add("item_tooltip_toright");
    } else if (tooltip_bbox.right > window.innerWidth) {
        item_tooltip.classList.add("item_tooltip_toleft");
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

// LIB
let SVG_LIST = {};
function isUppercase(word){
  return /^\p{Lu}/u.test( word );
}
function create_element(tag, classes, content) {
    content = content || "";
    el = document.createElement(tag);
    if (classes!="") { el.classList.add(...classes.split(" ")); }
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

        console.log(`Set ${url} to element`)
        return svgElement;
    } catch (error) {
        console.error('Error:', error);
    }
}
async function insert_svg(url, color, classes, parent) {
    if (SVG_LIST[url]===undefined) {
        SVG_LIST[url] = load_svg(url);
    };
    const cached = await SVG_LIST[url];
    const svgElement = cached.cloneNode(true);
    svgElement.style.color = color;
    if (classes!="") { svgElement.classList.add(...classes.split(" ")) };
    parent.appendChild(svgElement);
}

fetch_items();