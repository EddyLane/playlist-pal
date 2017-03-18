import '../sass/main.scss';
import 'phoenix_html';

const ELM_ELEMENT_ID = 'elm-root';

const Elm = require('../elm/Main.elm');

const targetElement = document.getElementById(ELM_ELEMENT_ID);

if (targetElement) {
    Elm.Main.embed(targetElement, {
        token: window.token || ''
    });
}