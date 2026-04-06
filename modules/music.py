import util, json

def parse():
    util.log("Converting music_by_filename.json to a list...")
    music_by_title = json.loads(util.read("music_by_title.json"))
    music_list_html = ""
    for title, modal in sorted(music_by_title.items()):
        context=modal.copy()
        file_exists = context.pop("file_exists")
        music_list_html += util.fill_template(util.read(f"templates/music/music_modal{"_missing"*int(not file_exists)}.html"),context)

    context = {
        "musicdata": music_list_html
    }
    util.write("gh-pages/music_list.html", util.fill_template(util.read("templates/music/music_list.html"),context))