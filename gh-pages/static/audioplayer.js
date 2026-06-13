/* Audio player */
let last_vol = 1/4;
let last_muted = false;
let last_song_id = -1;

let shuffle=false;
let loop=false;
let max_songs=0;

function set_audio_resource(obj) {
    if (max_songs>0) {
        if (last_song_id!==-1) { document.getElementById(last_song_id).classList.remove("music_playing") };
        obj.classList.add("music_playing");
    }
    last_song_id=obj.id;
    document.getElementById("music_title").innerHTML = apply_morecolors(obj.dataset.title) + " - " + apply_morecolors(obj.dataset.artist);
    
    let audio = document.getElementsByTagName("audio")[0];
    if (audio!==undefined) {
        last_vol = audio.volume;
        last_muted = audio.muted;
    }
    
    let mphtml = `<audio controls autoplay muted onended="nextsong();"><source src="filepath" type="audio/mpeg"></audio>`;
    const music_player = document.getElementById("music_player");
    music_player.innerHTML= mphtml.replace("filepath",obj.dataset.file);
    music_player.parentElement.classList.remove("hidden");
    
    audio = document.getElementsByTagName("audio")[0];
    audio.volume = last_vol;audio.muted = last_muted;
    audio.loop = loop;
    document.getElementsByTagName("audio")[0].volume = last_vol;

    navigator.mediaSession.metadata = new MediaMetadata({
        title: obj.dataset.title,
        artist: obj.dataset.artist.replace(" - ","").replace("- ",""),
    });
}

function nextsong() {
    if (max_songs>0) {
        let id = Number(last_song_id)+1;
        if (shuffle) { id=randint(0,max_songs) };
        if (id>max_songs) {id=0}; // loop back to start
        set_audio_resource(document.getElementById(id));
    }
}

function setloop(state) {
    audio = document.getElementsByTagName("audio")[0];
    audio.loop = state;loop = state;
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