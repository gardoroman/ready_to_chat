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

const users = {};

const logErrors = err => console.log(err);

// Assigns local media to the const variable stream
async function initStream(){
  try {
    let args = {audio: true, video: true, width: "1280"};
    const stream = await navigator.mediaDevices.getUserMedia(args);
    localStream = stream;
    document.getElementById('local-video').srcObject = stream;
  } catch(e){
    logErrors(e);
  }
}

function addUserConnection(userUuid){
  if (users[userUuid] === undefined){
    users[userUuid] = {
      peerConnection: null
    }
  }

  return users;
}

function removeUserConnection(userUuid){
  delete users[userUuid];
  
  return users;
}

/**
 * 
 * @param {*} lv: the `this` object from the LiveView hook
 * @param {*} fromUser: the user with which to create the connection
 * @param {*} offer: stores the SDP offer
 */
function createPeerConnection(lv, fromUser, offer){

  let newPeerConnection = new RTCPeerConnection({
    iceServers: [
      {urls: "stun:littlechat.app:3478"}
    ]
  })

  // add new connection to users object.
  users[fromUser].peerConnection = newPeerConnection;

  // adds local tracks, ie video/audio, to the RTCPeerConnection
  localStream.getTracks().forEach(track => newPeerConnection.addTrack(track, localStream));

  if (offer !== undefined){
    newPeerConnection.setRemoteDescription({type: "offer", sdp: offer});
    newPeerConnection.createAnswer()
      .then( answer => {
        newPeerConnection.setLocalDescription(answer);
        console.log("Sending Answer to requester", answer);
        lv.pushEvent("new_answer", {toUser: fromUser, description: answer});
      })
      .catch(logErrors);
    }

  newPeerConnection.onicecandidate = async candidate => {
    lv.pushEvent("new_ice_candidate", {toUser: fromUser, candidate});
  }

  if (offer === undefined){
    newPeerConnection.onnegotiationneeded = async () => {
      try {
        newPeerConnection.createOffer()
          .then(offer => {
            newPeerConnection.setLocalDescription(offer);
            console.log("Sending the following Offer to Requester:", offer);
            lv.pushEvent("new_sdp_offer", {toUser: fromUser, description: offer});
          });
      } catch(e) {
        logErrors(e)
      }
    }
  }

  newPeerConnection.ontrack = async event => {
    console.log("Track Received", event);
    document.getElementById(`video-remote-${fromUser}`).srcObject = event.streams[0];
  }

  return newPeerConnection;
  
}

let Hooks = {};

Hooks.JoinCall = {
  mounted(){
    initStream();
  }
};
Hooks.InitUser = {
  mounted(){
    addUserConnection(this.el.dataset.userUuid);
  },
  destroyed(){
    removeUserConnection(this.el.dataset.userUuid);
  }
}



let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});

window.addEventListener("phx:page-loading-start", () => NProgress.start());
window.addEventListener("phx:page-loading-stop", () => NProgress.done());



// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

