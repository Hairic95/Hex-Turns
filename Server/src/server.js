"use strict";
exports.__esModule = true;
//import http
const http = require("http");
//import ws
const ws = require("ws");
// import uniqid
const uniqid = require('uniqid');

var PORT = 12345;
var connectedPeers = 0;
var idIndex = 0;
var clients = [];


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////// LOBBIES DEFINITION AREA /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
const MSGTAG_ROOM_REFRESH = "ROOM_TAG_REFRESH";
const MSGTAG_ROOM_JOIN = "ROOM_TAG_JOIN";
const MSGTAG_ROOM_RESET = "ROOM_TAG_RESET";
const MSGTAG_ROOM_OCCUPIED = "ROOM_TAG_OCCUPIED";

const STATE_ROOM_EMPTY = "ROOM_STATE_EMPTY";
const STATE_ROOM_WAITING = "ROOM_STATE_WAITING";
const STATE_ROOM_STARTING = "ROOM_STATE_STARTING";
const STATE_ROOM_OCCUPIED = "ROOM_STATE_OCCUPIED";

var maxPlayRoomNumber = 20;
var playRooms = [];

class Room {
  constructor(id) {
    this.id = id;
    this.players = [];
    this.state = STATE_ROOM_EMPTY;
  }

  addPlayer(client){
    if (this.state == STATE_ROOM_EMPTY || this.state == STATE_ROOM_WAITING){

      var opponent = new Client(null);

      this.players.forEach((otherClient) => {
        if (!(otherClient === client)) {
          opponent = otherClient;
          otherClient.sendMessage(MSGTAG_ROOM_REFRESH, {opponent: client})
        }
      });

      client.state = CLIENT_STATE_WAITING;

      this.players.push(client);
      client.sendMessage(MSGTAG_ROOM_JOIN, {roomId: this.id, opponent: opponent});
    }
    else {
      client.sendMessage(MSGTAG_ROOM_OCCUPIED, {message: "Not enough room in the room."});
    }

    console.log(this);
    this.CheckRoomPlayers();
  }

  reset(){
    this.players.forEach((client) => {
      client.sendMessage(MSGTAG_ROOM_RESET, {message: "The room has been reset."});
      client.state = CLIENT_STATE_ONLINE;
    });
    this.players = [];
    this.CheckRoomPlayers();
  }
  CheckRoomPlayers() {
    switch (this.players.length) {
      case 0:
        this.state = STATE_ROOM_EMPTY;
        break;
      case 1:
        this.state = STATE_ROOM_WAITING;
        break;
      case 2:
        this.state = STATE_ROOM_STARTING;
        break;
      default:
        this.state = STATE_ROOM_EMPTY;
    }
  }
}



/////////////////////////////////////////////////////////////////////////////////
/////////////////////////// CLIENT DEFINITION AREA //////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
const CLIENT_STATE_PLAYING = "CLIENT_STATE_PLAYING";
const CLIENT_STATE_WAITING = "CLIENT_STATE_WAITING";
const CLIENT_STATE_ONLINE = "CLIENT_STATE_ONLINE";


class Client {
  constructor(id, socket) {
    this.id = id;
    this.socket = socket;
    this.state = CLIENT_STATE_ONLINE;
  }
  setName(username) {
    this.username = username;
  };
  // The message structure is divide by code, to make the client
  // understand which action to do and data with the needed information
  sendMessage(code, data) {
    var message = {
      tag: code,
      data: data
    };
    this.socket.send(JSON.stringify(message));
  }
  getJSON() {
    return {
      id: this.id,
      username: this.username,
      state: this.state
    }
  };
};

function AddClient(socket) {
  var newClient = new Client(uniqid(), socket);
  clients.push(newClient);
  return newClient;
}
function RemoveClient(client) {
  var oldClient = clients.find((element) => {
    if (element == client){
      clients.splice(oldClient, 1);
      return;
    }
  });

}

function ShowActiveConnections() {
  var playingPlayers = 0;
  clients.forEach((client) => {
    if (client.state == CLIENT_STATE_PLAYING)
      playingPlayers++;
  });
  return {
    total: clients.length,
    playing: playingPlayers
  };
}


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// SERVER CREATION /////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
const MSGTAG_SERVER_ROOMS = "SERVER_TAG_GET_ROOMS";
const MSGTAG_SERVER_PLAYER_NUMBERS = "SERVER_TAG_P_NUMBERS";

const MSGTAG_REQUEST_JOIN_ROOM = "REQUEST_JOIN_ROOM";
const MSGTAG_SERVER_PLAYER_DATA = "SERVER_TAG_P_DATA";

const httpServer = http.createServer(
  (req, res) => {
    res.end("Godot Websocket");
  }
);

CreateRooms(maxPlayRoomNumber);

function CreateRooms(maxNumber) {
  console.log("////Creating Rooms...");

  for(var i = 0; i < maxPlayRoomNumber; i++) {
    var newRoom = new Room(i + 1);
    playRooms.push(newRoom);
  }

  console.log("////Finished creating Rooms...");
}

httpServer.listen(PORT);

const wsServer = new ws.Server({server: httpServer});

wsServer.on('listening', () => {
  console.log("Websocket server listening on " + PORT);

  const DCCheckInterval = setInterval(function checkIsAlive() {
    wsServer.clients.forEach((socket) => {
      if (socket.isAlive === false) {
        var client = getClientBySocket(socket);
        console.log("Couldnt contact " + client.id + ". Disconnecting user.");
        clients.RemoveClient(client);
        return ws.terminate();
      }
    });
  }, 5000);

  const TESTInterval = setInterval(function ping() {
    clients.forEach((client) => {
      //if (socket.isAlive === true) {
        client.socket.send("ping");
        console.log("Ping to ", client.id);
      //}
    });
    console.log(clients.length);
  }, 1000);
});

wsServer.on("connection", (socket, request) => {
  var connectedClient = AddClient(socket);
  connectedClient.username = "Dude_" + connectedClient.id;
  /*clients.forEach((c) => {
    if (c === newClient)
      return;
    c.socket.send(":UC" + client.getJSON());
  });*/
  connectedClient.sendMessage(MSGTAG_SERVER_PLAYER_DATA, {id: connectedClient.id})
  console.log("New Client" + connectedClient.username + " connected");

  RefreshLobbyForClient(connectedClient);


  socket.on("message", (message) => {
    if (typeof (message) !== 'string') {
            // socket.close(4000, 'INVALID TRANSFER MODE')
      console.log('Invalid message from ' + request.connection.remoteAddress);
      return;
    }

    var data = JSON.parse(message);

    switch (data.tag) {
      case MSGTAG_REQUEST_JOIN_ROOM:
        var player = clients.find((client) => {
          if (client.id == data.data.playerId)
            return client;
        })
        playRooms[data.data.roomId -1].addPlayer(player);
        break;
      default:

    }

  });

  socket.on("close", (code) => {
    console.log("Connection interrupted with " + connectedClient.username + " Code: " + code);
    RemoveClient(connectedClient);

    /*wsServer.clients.forEach((socket) => {
      var client = getClientBySocket(socket);
    })*/
  });
});

function RefreshLobbyForClient(client) {
  client.sendMessage(MSGTAG_SERVER_ROOMS, {rooms: playRooms});
  client.sendMessage(MSGTAG_SERVER_PLAYER_NUMBERS, {players: ShowActiveConnections()});
}
