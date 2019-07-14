extends Resource
class_name Unit

var id = ""

var position = Vector2(0, 0)
var movement = 5

var actions : Array = []

signal play_anim(id, anim_name)

func _ready():
	pass

var current_state = "k"

func dies():
	current_state = "dead"
	emit_signal("play_anim", id, "dead")

