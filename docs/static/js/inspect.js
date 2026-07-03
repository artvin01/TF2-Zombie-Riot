SRC_URL = "https://github.com/artvin01/TF2-Zombie-Riot/blob/master/"
// reference: https://unixpapa.com/js/key.html
document.addEventListener(("click"), (evt) => {
  if (document.body.classList.contains("inspectmode")) {
    if (evt.target.dataset.src !== undefined && evt.target.dataset.src !== "?#L-1") {
      evt.preventDefault();
      let url = SRC_URL + evt.target.dataset.src;
      window.open(url, "_blank");
    }
  }
});
document.addEventListener("keydown", (event) => {
  if (event.code === "KeyG" && event.ctrlKey) {
    event.preventDefault();
    if (document.body.classList.contains("inspectmode")) {
      document.body.classList.remove("inspectmode");
    } else {
      document.body.classList.add("inspectmode");
    }
  };
})
