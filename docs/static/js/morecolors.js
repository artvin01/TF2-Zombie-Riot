let MORECOLORS_JSON = {}
let MORECOLORS_LOADED = false;
async function init_morecolors() {
    try {
        const response = await fetch("static/data/morecolors.json");
        if (!response.ok) {
            throw new Error(`[init_morecolors] Response status: ${response.status}`);
        }
        MORECOLORS_JSON = await response.json();
        MORECOLORS_LOADED = true;
    } catch (error) {
        console.error(`[init_morecolors] ${error.message}`);
    }
}
init_morecolors()

function apply_morecolors(str_) {
    let newstr = `<span>${str_}</span>`;
    let has_replaced=false;
    for (const [colorname,_] of Object.entries(MORECOLORS_JSON)) {
        newstr = newstr.replaceAll(`{${colorname}}`, `</span><span class="mc_${colorname}">`)
        if (str_.includes(`{${colorname}}`)) {
            has_replaced=true
        };
    };
    newstr = newstr.replaceAll("<span></span>",""); // remove empty divs
    if (has_replaced) { return newstr };
    return str_
}
function remove_morecolors(str_) {
    for (const [colorname,_] of Object.entries(MORECOLORS_JSON)) {
        str_ = str_.replaceAll(`{${colorname}}`, "")
    };
    return str_
}


function apply_morecolors_src(str_, src_obj) {
    let newstr = `<span data-src="${__html_src__(src_obj)}">${str_}</span>`;
    let has_replaced=false;
    for (const [colorname,_] of Object.entries(MORECOLORS_JSON)) {
        newstr = newstr.replaceAll(`{${colorname}}`, `</span><span class="mc_${colorname}" data-src="${__html_src__(src_obj)}">`)
        if (str_.includes(`{${colorname}}`)) {
            has_replaced=true
        };
    };
    newstr = newstr.replaceAll("<span></span>",""); // remove empty divs
    return newstr
}
function __html_src__(src_obj) { /* local use only */
    if (typeof src_obj === Array) {
        return `${src_obj[0]}#L${src_obj[1][0]}-L${src_obj[1][1]}`;
    } else {
        return `${src_obj[0]}#L${src_obj[1]}`;
    }
}