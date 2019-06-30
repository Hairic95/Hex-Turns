extends Node

var id = ""

var position = Vector2(0, 0)
var movement = 5

export (PackedScene) var action_ref

signal play_anim(id, anim_name)

func _ready():
	pass # Replace with function body.

var current_state = "k"

func dies():
	current_state = "dead"
	emit_signal("play_anim", id, "dead")

func get_actions():
	return $moves.get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
