/* Audio player */
let last_vol = 1.0;
let last_muted = false;
function set_audio_resource(obj) {
    document.getElementById("music_title").innerHTML = apply_morecolors(obj.getAttribute("title")) + " - " + apply_morecolors(obj.getAttribute("artist"));
    let mphtml = `<audio controls autoplay muted><source src="filepath" type="audio/mpeg"></audio>`;
    const music_player = document.getElementById("music_player");
    let audio = document.getElementsByTagName("audio")[0];
    if (audio!==undefined) {
        last_vol = audio.volume;
        last_muted = audio.muted;
    }
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