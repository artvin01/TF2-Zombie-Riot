/* Audio player */
function set_audio_resource(obj) {
    document.getElementById("music_title").innerHTML = obj.getAttribute("name");
    let mphtml = `<audio controls autoplay><source src="filepath" type="audio/mpeg"></audio>`;
    const music_player = document.getElementById("music_player");
    music_player.innerHTML= mphtml.replace("filepath",obj.getAttribute("file"));
    music_player.parentElement.classList.remove("hidden");
}