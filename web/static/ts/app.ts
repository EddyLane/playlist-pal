import '../css/app.css';
import 'phoenix_html';
import {Socket} from 'phoenix'

const Elm = require('../elm/Main.elm');

window.user = window.user || { "username": "anon", "name": "Anonymous" };
window.token = window.token || "";

const targetElement = document.getElementById('elm-root');
const flags = {
    user: window.user,
    token: window.token
};

// const socket = new Socket('/socket', {
//     logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }
// });
//
// socket.connect({
//     guardian_token: window.token
// });

Elm.Main.embed(targetElement, flags);