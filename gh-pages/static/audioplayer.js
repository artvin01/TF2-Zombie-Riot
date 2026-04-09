/* Audio player */
let last_vol = 1.0;
let last_muted = false;
let last_song_id = -1;

let playlist_mode=false;

let shuffle=false;
let max_songs = 0;

function set_audio_resource(obj) {
    last_song_id=obj.id;
    document.getElementById("music_title").innerHTML = apply_morecolors(obj.getAttribute("title")) + " - " + apply_morecolors(obj.getAttribute("artist"));
    
    let audio = document.getElementsByTagName("audio")[0];
    if (audio!==undefined) {
        last_vol = audio.volume;
        last_muted = audio.muted;
    }
    
    let onend = `onended="nextsong();"`
    let mphtml = `<audio controls autoplay muted ${onend}><source src="filepath" type="audio/mpeg"></audio>`;
    const music_player = document.getElementById("music_player");
    music_player.innerHTML= mphtml.replace("filepath",obj.getAttribute("file"));
    music_player.parentElement.classList.remove("hidden");
    
    audio = document.getElementsByTagName("audio")[0]
    audio.volume = last_vol;audio.muted = last_muted;
    document.getElementsByTagName("audio")[0].volume = last_vol;

    navigator.mediaSession.metadata = new MediaMetadata({
        title: obj.getAttribute("title"),
        artist: obj.getAttribute("artist").replace(" - ","").replace("- ",""),
    });
}

function nextsong() {
    if (playlist_mode) {
        let id = Number(last_song_id)+1
        if (shuffle) { id=randint(0,max_songs) };
        set_audio_resource(document.getElementById(id));
    }
}

function randint(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function get_song_count() {
    const validIds = Array.from(document.getElementsByClassName('audio')).map(element => {
        const numMatch = element.id.match(/\d+/);
        return numMatch ? parseInt(numMatch[0], 10) : NaN;
    }).filter(id => !isNaN(id));
    if (validIds.length > 0) {
        max_songs = Math.max(...validIds);
    }
}


window.onload = get_song_count;