# Hex-Turns
A Godot-based turn based tactical engine for games
A Godot-based turn based tactical engine for games (currently WIP and update every once in a while).

Sprite are made with PixaVoxet (https://myska.itch.io/pixavoxet)

The game uses a Node JS Web API to handle players connection and can easily used on your own servers
to make the server work install Node.JS and add to the project folder ws (WebSocket) and uniqid.

The client runs on Godot 3.0 and forward.

## How to run the server

### Install dependencies

```sh
cd Server
npm install
```

### Start the server

```sh
cd Server
npm start
```

## How to run the client

The steps are the usual for every Godot project: scane the Client folder and start it (or create an executable and run it).

To change the IP address to which the client will connect, you have to manually modify 
this line: [Client/src/Autoloads/API_CONNECTION.gd](https://github.com/Hairic95/Hex-Turns/blob/master/Client/src/Autoloads/API_CONNECTION.gd#L12)