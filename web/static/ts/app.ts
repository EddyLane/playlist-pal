import '../sass/main.scss';
import 'phoenix_html';

const ELM_ELEMENT_ID = 'elm-root';

const Elm = require('../elm/Main.elm');

Elm.Main.embed(document.getElementById(ELM_ELEMENT_ID), {
    token: window.token || ''
});