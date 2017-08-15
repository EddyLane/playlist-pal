import '../sass/main.scss';

const app = require('../elm/Main.elm').Main.fullscreen(localStorage.session || null);

app.ports.storeSession.subscribe(session => localStorage.session = session);

window.addEventListener("storage", function(event) {
    if (event.storageArea === localStorage && event.key === "session") {
        app.ports.onSessionChange.send(event.newValue);
    }
}, false);