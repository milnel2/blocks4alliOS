function setTheme(theme) {
    document.documentElement.className = theme;
    localStorage.setItem("theme", theme);
}
window.onload = _ =>
    setTheme(
    localStorage.getItem("theme")
    )