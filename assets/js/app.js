// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import NProgress from "nprogress"
import regeneratorRuntime from "regenerator-runtime"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let localStream = null;

// Assigns local media to the const variable stream
async function initStream(){
  try {
    let args = {audio: true, video: true, width: "1280"};
    const stream = await navigator.mediaDevices.getUserMedia(args);
    localStream = stream;
    document.getElementById('local-video').srcObject = stream;
  } catch(e){
    console.log(e);
  }
}

let Hooks = {};
Hooks.JoinCall = {
  mounted(){
    initStream();
  }
};

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});

window.addEventListener("phx:page-loading-start", () => NProgress.start());
window.addEventListener("phx:page-loading-stop", () => NProgress.done());



// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// liveSocket.disableLatencySim()
window.liveSocket = liveSocket

