/* Audio player */
function set_audio_resource(obj) {
    document.getElementById("music_title").innerHTML = obj.getAttribute("title") + " - " + obj.getAttribute("artist");
    let mphtml = `<audio controls autoplay><source src="filepath" type="audio/mpeg"></audio>`;
    const music_player = document.getElementById("music_player");
    music_player.innerHTML= mphtml.replace("filepath",obj.getAttribute("file"));
    music_player.parentElement.classList.remove("hidden");

    navigator.mediaSession.metadata = new MediaMetadata({
        title: obj.getAttribute("title"),
        artist: obj.getAttribute("artist").replace(" - ","").replace("- ",""),
    });
}