import '../css/app.css';
import 'phoenix_html';

window.user = window.user || { "username": "anon", "name": "Anonymous" };

const Elm = require('../elm/Main.elm');
const targetElement = document.getElementById('elm-root');

Elm.Main.embed(targetElement, {
    user: window.user
});