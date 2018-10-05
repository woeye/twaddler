// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import appSocket from "./socket";
import * as AbsintheSocket from "@absinthe/socket";
import { GraphQLClient } from "graphql-request";

function appendMessage(msg) {
    //console.log(msg);
    let p = document.createElement("p");
    let text = document.createTextNode(`(${msg.user.username}) ${msg.text}`);
    p.appendChild(text);
    document.getElementById("messages").appendChild(p);
}

const query = `{
    getMessages(conversationId: "45f7b8e4-a477-4cac-908a-5e8d62ee2f66", limit: 50, offset: 0) {
        user { username }
        posted
        text
    }
}`

const client = new GraphQLClient("http://localhost:4000/api", { headers: {} });
client.request(query, {}).then(result => {
    //console.log(result.getMessages);
    result.getMessages.forEach(msg => appendMessage(msg));
});

const operation = `
  subscription messagePosted($convId: ID!) {
    messagePosted(conversationId: $convId) {
      text
      user { username }
      posted
    }
  }
`;

const notifier = AbsintheSocket.send(appSocket, {
    operation,
    variables: {convId: "45f7b8e4-a477-4cac-908a-5e8d62ee2f66"}
});

const logEvent = eventName => (...args) => console.log(eventName, ...args);

const updatedNotifier = AbsintheSocket.observe(appSocket, notifier, {
  onAbort: logEvent("abort"),
  onError: logEvent("error"),
  onStart: logEvent("open"),
  onResult: msg => {
    console.log("got post", msg);
    if ("messagePosted" in msg.data) {
        appendMessage(msg.data.messagePosted)
    }
  }
});

const input = document.getElementById("message");
input.addEventListener("keyup", evt => {
    if(evt.key == 'Enter') {
        // console.log(input.value);
        const mutation = `mutation {
            postMessage(
                conversationId: "45f7b8e4-a477-4cac-908a-5e8d62ee2f66",
                userId:"428ef4e8-f5f8-44c1-9d78-b857c9c4499d",
                text: "${input.value}"
            ) {
                uuid
            }
        }`
        client.request(mutation, {}).then(result => {
            console.log(result);
            input.value = "";
            // result.getMessages.forEach(msg => appendMessage(msg));
        }).catch(error => {
            console.error(error);
        })
    }
});
