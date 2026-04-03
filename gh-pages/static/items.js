let filter_tag = "";
let filter_pap = false;
let filter_cfghidden = false;
let filter_content = "";
/* Filter by TAG */
function filter_set_tag(tag) {
    const tags = document.getElementById("taglist").getElementsByTagName("div");
    for (var i=0, item; item = tags[i]; i++) {
        if (item.textContent.includes(tag)) {
            item.classList.add("btn-active");
        } else {
            item.classList.remove("btn-active");
        }
    }

    if (tag==="All") {tag=""};
    filter_tag = tag;
    filter();
}
function filter_set_pap(checkbox) {
    filter_pap = checkbox.checked;
    filter();
}
function filter_set_cfghidden(checkbox) {
    filter_cfghidden = checkbox.checked;
    filter();
}
function filter() {
    const r = document.getElementsByTagName("details");
    for (var i=0, item; item = r[i]; i++) {
        remove_items_by_tag(item);
    }
}

function hide_on_cond(element, hide, unhide, ah) {
    if (!ah) {
        if (hide) {
            element.classList.add("hidden");
            return true;
        } else if (unhide) {
            element.classList.remove("hidden");
            return false;
        }
        return false
    }
    return true
}

function remove_items_by_tag(root) {
    const la = Array.prototype.slice.call(root.getElementsByTagName("li"),0);
    const lb = Array.prototype.slice.call(root.getElementsByTagName("div"),0);
    const l = la.concat(lb);
    let has_visible_items = false;
    for (var i=0, item; item = l[i]; i++) {
        if (item.hasAttribute("weapon_tags")) {
            /* Filter by tag */
            let attr = item.getAttribute("weapon_tags");
            let already_hidden = hide_on_cond(
                item,
                !attr.includes(filter_tag),
                true,
                false
            )

            /* Filter pap show/don't show */
            already_hidden = hide_on_cond(
                item,
                !filter_pap && item.classList.contains("weapon_pap"),
                filter_pap && item.classList.contains("weapon_pap"),
                already_hidden
            )

            /* Filter cfghidden weapon */
            already_hidden = hide_on_cond(
                item,
                !filter_cfghidden && item.classList.contains("weapon_cfghidden"),
                filter_cfghidden && item.classList.contains("weapon_cfghidden"),
                already_hidden
            )

            /* Filter by custom text */
            already_hidden = hide_on_cond(
                item,
                !item.textContent.toLowerCase().includes(filter_content.toLowerCase()),
                true,
                already_hidden
            )

            if (!already_hidden) {has_visible_items=true};
        }
    }
    if (!has_visible_items) {
        root.classList.add("hidden");
    } else {
        root.classList.remove("hidden");
    }
}

/* Filter by CUSTOM STRING */
const item_filter_text = document.getElementById("item_filter_input");
item_filter_text.addEventListener('input', function (evt) {
    filter_content = evt.target.value;
    filter();
});

/* Accessibility */
document.onkeydown = (e) => {
  if (e.key === "Enter") {
    document.activeElement.click();
  }
};



/*
Custom right click modal
const all_items = document.getElementsByTagName("li");
let last_popup = null;
function show_popup(item) {
    if (last_popup!==null) { hide_popup(last_popup) };
    const pap_container = item.getElementsByClassName("tooltip_pap")[0];
    const item_container = item.getElementsByClassName("tooltip")[0];
    pap_container.classList.remove("hidden");
    item_container.classList.add("hidden");
    pap_container.style["top"] = "125%";
    last_popup = item;
}
function hide_popup(item) {
    const pap_container = item.getElementsByClassName("tooltip_pap")[0];
    const item_container = item.getElementsByClassName("tooltip")[0];
    pap_container.classList.add("hidden");
    item_container.classList.remove("hidden");
    pap_container.style["top"] = "110%";
}
for (var i=0, item; item = all_items[i]; i++) {
    item.addEventListener('contextmenu', function(e) {
        show_popup(e.target);
        e.preventDefault();
    }, false);
}
document.addEventListener('click', function(event) {
    if (last_popup!==null) {
        if (event.target !== last_popup) {
            hide_popup(last_popup);
        }
    }
});*/