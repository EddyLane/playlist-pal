import '../sass/main.scss';
import 'phoenix_html';

const ELM_ELEMENT_ID = 'elm-root';
const FLAGS = {
    token: window.token || ''
};
const targetElement = document.getElementById(ELM_ELEMENT_ID);

if (targetElement) {

    console.log('local storage session', JSON.parse(localStorage.session || "{}"));

    const app = require('../elm/Main.elm').Main.embed(targetElement, localStorage.session || null);

    app.ports.storeSession.subscribe(function(session) {

        console.log('port out:', session);

        localStorage.session = session;
    });

    window.addEventListener("storage", function(event) {

        console.log('port in:', event);

        if (event.storageArea === localStorage && event.key === "session") {
            app.ports.onSessionChange.send(event.newValue);
        }
    }, false);

}