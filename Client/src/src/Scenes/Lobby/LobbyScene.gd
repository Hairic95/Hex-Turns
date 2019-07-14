extends Control

export (PackedScene) var WebRoomAccess_reference

func _ready():
	
	API_CONNECTION.connect("refresh_rooms", self, "RefreshRoom")

func LobbyScene():
	RefreshRoom()
func RefreshRoom():
	for room in API_CONNECTION.playable_rooms:
		var newWebRoomAccess : WebRoomAccess = WebRoomAccess_reference.instance()
		
		$Rooms/Grid.add_child(newWebRoomAccess)
		
		newWebRoomAccess.WebRoomAccess(room.id)
		
		for player in room.players:
			newWebRoomAccess.AddPlayer(player.username)
		
		newWebRoomAccess.connect("PlayerJoiningToRoom", self, "JoinRoom")

func JoinRoom(roomId):
	API_CONNECTION.SendDataToAPI(CONSTS.REQUEST_JOIN_ROOM, {"roomId" : roomId, "playerId" : API_CONNECTION.connectionId})
