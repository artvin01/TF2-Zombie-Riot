import util
import json

util.log("Converting music_by_filename.json to a list...")
music_by_title = json.loads(util.read("music_by_title.json"))
music_list_html = ""
music_idx = 0
for _, modal in sorted(music_by_title.items()):
    modal["musictitle"] = modal["musictitle"].replace("zombiesurvival/","")
    if modal["file_exists"] and "intro" not in modal["filepath"]:
        modal['audio"'] = f'audio" id="{music_idx}"' # class="audio" => class="audio" id="<int>"
        music_idx += 1
        music_list_html += util.musicmodal_to_html(modal)

context = {
    "musicdata": music_list_html
}
util.write("gh-pages/music_list.html", util.fill_template(util.read("templates/music/music_list.html"),context))
