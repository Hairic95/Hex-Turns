extends Node

var wsc = WebSocketClient.new()

var connectionId = ""

func _ready():
	print("START")
	connect_to_server()

func connect_to_server():
	wsc.connect_to_url("ws://192.168.8.14:12345")
	
	wsc.connect("data_received", self, "_on_data_received")
	wsc.connect("connection_established", self, "_on_connection_established")
	wsc.connect("connection_closed", self, "_on_connection_closed")
	wsc.connect("connection_error", self, "_on_connection_error")
	wsc.connect("server_close_request", self, "_on_close_request")

"""
Function that filters any message that player receives from the WebAPI
"""
func _on_data_received():
	var data = wsc.get_peer(1).get_packet().get_string_from_utf8()
	
	
	var parsed_data : Dictionary = parse_json(data)
	
	if parsed_data != null and parsed_data.has("tag"):
		match(parsed_data["tag"]):
			CONSTS.MSGTAG_SERVER_ROOMS:
				playableRooms = parsed_data["data"]["rooms"]
				emit_signal("refreshRooms")
			CONSTS.MSGTAG_SERVER_PLAYER_DATA:
				yourData = parsed_data["data"]
				connectionId = parsed_data["data"]["id"]
			CONSTS.MSGTAG_ROOM_JOIN:
				currentRoom = parsed_data["data"]
				emit_signal("showLobby")
			CONSTS.MSGTAG_ROOM_REFRESH:
				currentRoom = parsed_data["data"]
				emit_signal("showLobby")
			CONSTS.MSGTAG_ROOM_EXIT:
				currentRoom = null
				emit_signal("outOfLobby")
				RefreshLobbies()
			CONSTS.MSGTAG_ROOM_START_GAME:
				unitLists = parsed_data["data"]["units"]
				emit_signal("startGame")

"""
Lobby Managing
"""

signal startGame()
signal outOfLobby()
signal showLobby()
signal refreshRooms()
var playableRooms = []

var currentRoom
func GetPlayersInRoomIds() -> Array:
	var ids = []
	if currentRoom != null and currentRoom.keys().has("players"):
		for player in currentRoom.players:
			ids.append(player.id)
	return ids
func GetPlayersInRoomNames() -> Array:
	var ids = []
	if currentRoom != null and currentRoom.keys().has("players"):
		for player in currentRoom.players:
			ids.append(player.username)
	return ids

func RefreshLobbies():
	SendDataToAPI(CONSTS.REQUEST_ROOMS_REFRESH, {})

func _on_connection_established(protocol : String):
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	print("Connected to WebSocket Server!")

func _on_connection_closed(was_clean_close : bool):
	print("disconnected. clean? %s" %was_clean_close)

func _on_connection_error():
	print("connection error")


func _on_close_request(code :int, reason :String):
	print("close request %s, %s" %[code, reason])

func _process(delta):
	var status = wsc.get_connection_status()
	if status == WebSocketClient.CONNECTION_CONNECTING or status == WebSocketClient.CONNECTION_CONNECTED:
		wsc.poll()

func SendDataToAPI(msg_tag, msg_data):
	var message = {
		"tag": msg_tag,
		"data": msg_data
	}
	wsc.get_peer(1).put_packet((JSON.print(message)).to_utf8())

func ExitRoom():
	SendDataToAPI(CONSTS.REQUEST_LEAVE_ROOM, {})

var yourData = {
	"id" : 1
}

func StartGame():
	if currentRoom != null:
		SendDataToAPI(CONSTS.REQUEST_START_GAME, {"roomId": currentRoom.id})

var unitLists = [];
func GetPlayerUnits():
	return unitLists
