import '../sass/main.scss';
import 'phoenix_html';

const ELM_ELEMENT_ID = 'elm-root';
const FLAGS = {
    token: window.token || ''
};
const targetElement = document.getElementById(ELM_ELEMENT_ID);

if (targetElement) {
    require('../elm/Main.elm').Main.embed(targetElement, FLAGS);
}