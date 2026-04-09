let MORECOLORS_JSON = {}
async function init_morecolors() {
    try {
        const response = await fetch("static/morecolors.json");
        if (!response.ok) {
            throw new Error(`[init_morecolors] Response status: ${response.status}`);
        }
        MORECOLORS_JSON = await response.json();
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