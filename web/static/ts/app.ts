import '../css/app.css';
import 'phoenix_html';

const Elm = require('../elm/Main.elm');

Elm.Main.embed(document.getElementById('elm-root'));