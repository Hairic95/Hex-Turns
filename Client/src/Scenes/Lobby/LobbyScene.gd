extends Control

signal changeScene(strScene)

export (PackedScene) var WebRoomAccess_reference

func _ready():
	API_CONNECTION.connect("refreshRooms", self, "RefreshRoom")
	API_CONNECTION.connect("showLobby", self, "ShowLobby")
	API_CONNECTION.connect("outOfLobby", self, "OutOfLobby")
	API_CONNECTION.connect("startGame", self, "StartGame")

func LobbyScene():
	CreateRooms()
func CreateRooms():
	for room in API_CONNECTION.playableRooms:
		var newWebRoomAccess : WebRoomAccess = WebRoomAccess_reference.instance()
		
		$Rooms/Grid.add_child(newWebRoomAccess)
		
		newWebRoomAccess.WebRoomAccess(room.id)
		
		for player in room.players:
			newWebRoomAccess.AddPlayer(player.username)
		
		newWebRoomAccess.connect("PlayerJoiningToRoom", self, "JoinRoom")

func RefreshRoom():
	if $Rooms/Grid.get_child_count() == 0:
		CreateRooms()
	
	for room in API_CONNECTION.playableRooms:
		for child in $Rooms/Grid.get_children():
			if child is WebRoomAccess and child.roomId == room.id:
				child.UpdateWebRoomAccess(room)
				break
	
	var names = API_CONNECTION.GetPlayersInRoomNames()
	if names.size() > 0:
		$BattlePanel/Player1.text = names[0]
		if names.size() == 2:
			$BattlePanel/Player2.text = names[1]
	

var outsidePosition = Vector2(-125, -400)
var insidePosition = Vector2(50, 25)

func JoinRoom(roomId):
	API_CONNECTION.SendDataToAPI(CONSTS.REQUEST_JOIN_ROOM, {"roomId" : roomId, "playerId" : API_CONNECTION.yourData.id})
func ShowLobby():
	ToggleBattlePanel(true)


func ToggleBattlePanel(battlePanelIsOut : bool):
	var final_pos = insidePosition
	if !battlePanelIsOut:
		final_pos = outsidePosition
	print("SHOW")
	$BattlePanel.set_position(final_pos)


func _on_ExitLobbyButton_pressed():
	API_CONNECTION.ExitRoom()
func OutOfLobby():
	ToggleBattlePanel(false)
	$BattlePanel/Player1.text = ""
	$BattlePanel/Player2.text = ""

func StartGame():
	emit_signal("changeScene", "battle")


func _on_StartButton_pressed():
	API_CONNECTION.StartGame()
