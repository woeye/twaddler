import * as AbsintheSocket from "@absinthe/socket";
import {Socket as PhoenixSocket} from "phoenix";

const absintheSocket = AbsintheSocket.create(
  new PhoenixSocket("ws://localhost:4000/socket")
);

export default absintheSocket;
