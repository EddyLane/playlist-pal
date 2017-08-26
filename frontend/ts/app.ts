import '../sass/main.scss';

console.log(window.__env);

const app = require('../elm/Main.elm').Main.fullscreen({
    session: localStorage.session || null,
    config: {
        apiUrl: window.__env.API_URL
    }
});

app.ports.storeSession.subscribe(session => localStorage.session = session);

window.addEventListener("storage", function(event) {
    if (event.storageArea === localStorage && event.key === "session") {
        app.ports.onSessionChange.send(event.newValue);
    }
}, false);