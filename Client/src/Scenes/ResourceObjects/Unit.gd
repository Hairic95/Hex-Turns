extends Resource
class_name Unit

var id = ""
var playerId = 1

var position = Vector2(0, 0)
var movement = 5

var actions : Array = []
func GetActions():
	return actions

func _init(actions : Array, position : Vector2):
	self.position = position
	
	for action in actions:
		var newAction = Action.new(action.type, action.damage, action.radius)
		self.actions.append(newAction)
		

signal play_anim(id, anim_name)

var current_state = "k"

func dies():
	current_state = "dead"
	emit_signal("play_anim", id, "dead")

