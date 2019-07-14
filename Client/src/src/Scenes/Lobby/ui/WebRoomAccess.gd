extends Panel
class_name WebRoomAccess

var roomId = 0;
func WebRoomAccess(id):
	roomId = id

func AddPlayer(player_name : String):
	$PlayersList.add_item(player_name)
func ResetRoomAccess():
	$PlayersList.clear()

signal PlayerJoiningToRoom(roomId)

func _on_JoinButton_pressed():
	emit_signal("PlayerJoiningToRoom", roomId)
